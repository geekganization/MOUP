//
//  CalendarService.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//

import RxSwift
import FirebaseFirestore

protocol CalendarServiceProtocol {
    func addUserToCalendarSharedWith(calendarId: String, uid: String) -> Observable<Void>
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?>
    func addEventToCalendar(calendarId: String, event: CalendarEvent) -> Observable<Void>
    func deleteEventFromCalendarIfPermitted(calendarId: String, eventId: String, uid: String) -> Observable<Void>
    func updateEventInCalendar(calendarId: String, eventId: String, event: CalendarEvent) -> Observable<Void>
}

final class CalendarService: CalendarServiceProtocol {
    private let db = Firestore.firestore()
    
    /// 캘린더의 sharedWith 배열에 사용자의 uid를 추가합니다.
    ///
    /// - Parameters:
    ///   - calendarId: 공유할 캘린더의 Firestore documentID
    ///   - uid: 공유에 추가할 사용자 UID
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: calendars/{calendarId}/sharedWith (arrayUnion)
    func addUserToCalendarSharedWith(calendarId: String, uid: String) -> Observable<Void> {
        let calendarRef = db.collection("calendars").document(calendarId)
        return Observable.create { observer in
            calendarRef.updateData([
                "sharedWith": FieldValue.arrayUnion([uid])
            ]) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    /// 주어진 근무지 ID(workplaceId)에 연결된 캘린더의 ID를 조회합니다.
    ///
    /// - Parameter workplaceId: 연동할 근무지의 Firestore documentID
    /// - Returns: 연결된 캘린더의 calendarId (문서 ID) 또는 nil
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?> {
        return Observable.create { observer in
            let listener = self.db.collection("calendars")
                .whereField("workplaceId", isEqualTo: workplaceId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    let calendarId = snapshot?.documents.first?.documentID
                    observer.onNext(calendarId)
                }
            return Disposables.create { listener.remove() }
        }
    }
    
    /// 특정 캘린더에 근무(이벤트)를 추가합니다.
    ///
    /// - Parameters:
    ///   - calendarId: 캘린더 문서 ID
    ///   - event: 추가할 CalendarEvent 모델
    /// - Returns: 성공 시 Void, 실패 시 에러 Observable
    func addEventToCalendar(calendarId: String, event: CalendarEvent) -> Observable<Void> {
        let eventRef = db.collection("calendars").document(calendarId).collection("events").document()
        let data: [String: Any] = [
            "title": event.title,
            "eventDate": event.eventDate,
            "startTime": event.startTime,
            "endTime": event.endTime,
            "createdBy": event.createdBy,
            "year": event.year,
            "month": event.month,
            "day": event.day,
            "routineIds": event.routineIds,
            "repeatDays": event.repeatDays,
            "memo": event.memo
        ]
        return Observable.create { observer in
            eventRef.setData(data) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    /// 특정 캘린더의 근무(이벤트)를 수정합니다.
    ///
    /// - Parameters:
    ///   - calendarId: 캘린더 문서 ID
    ///   - eventId: 수정할 이벤트의 문서 ID
    ///   - event: 수정할 CalendarEvent 모델
    /// - Returns: 성공 시 Void, 실패 시 에러 Observable

    func updateEventInCalendar(
        calendarId: String,
        eventId: String,
        event: CalendarEvent
    ) -> Observable<Void> {
        let eventRef = db.collection("calendars").document(calendarId).collection("events").document(eventId)
        let data: [String: Any] = [
            "title": event.title,
            "eventDate": event.eventDate,
            "startTime": event.startTime,
            "endTime": event.endTime,
            "createdBy": event.createdBy,
            "year": event.year,
            "month": event.month,
            "day": event.day,
            "routineIds": event.routineIds,
            "repeatDays": event.repeatDays,
            "memo": event.memo
        ]
        return Observable.create { observer in
            eventRef.updateData(data) { error in
                if let error = error as NSError? {
                    if error.domain == FirestoreErrorDomain,
                       error.code == FirestoreErrorCode.permissionDenied.rawValue {
                        // 파이어스토어 권한 에러 (보안 규칙 위반)
                        print("권한 없음: Firestore Security Rule에 의해 거부됨")
                        observer.onError(
                            NSError(
                                domain: "CustomErrorDomain",
                                code: error.code,
                                userInfo: [NSLocalizedDescriptionKey: "권한이 없습니다. Security Rule에 의해 거부되었습니다."]
                            )
                        )
                    } else {
                        observer.onError(error)
                    }
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }


    
    /// 권한 체크 후 삭제 (owner, sharedWith, createdBy)
    func deleteEventFromCalendarIfPermitted(calendarId: String, eventId: String, uid: String) -> Observable<Void> {
        let calendarRef = db.collection("calendars").document(calendarId)
        let eventRef = calendarRef.collection("events").document(eventId)
        
        return Observable.create { observer in
            // 1. 캘린더 권한 확인
            calendarRef.getDocument { calendarSnap, calendarError in
                guard let calendarData = calendarSnap?.data(),
                      let ownerId = calendarData["ownerId"] as? String,
                      let sharedWith = calendarData["sharedWith"] as? [String] else {
                    observer.onError(NSError(domain: "CalendarService", code: 404, userInfo: [NSLocalizedDescriptionKey: "캘린더 정보를 찾을 수 없습니다."]))
                    return
                }
                
                // 2. 이벤트 정보 확인
                eventRef.getDocument { eventSnap, eventError in
                    guard let eventData = eventSnap?.data(),
                          let createdBy = eventData["createdBy"] as? String else {
                        observer.onError(NSError(domain: "CalendarService", code: 404, userInfo: [NSLocalizedDescriptionKey: "이벤트 정보를 찾을 수 없습니다."]))
                        return
                    }
                    
                    // 3. 권한 체크: 내가 오너 or 내가 만든 이벤트만 허용
                    let isPermitted =
                    (ownerId == uid)
                    || (createdBy == uid)
                    if !isPermitted {
                        observer.onError(NSError(domain: "CalendarService", code: 403, userInfo: [NSLocalizedDescriptionKey: "이벤트를 삭제할 권한이 없습니다."]))
                        return
                    }
                    
                    // 4. 실제 삭제 진행
                    eventRef.delete { deleteError in
                        if let deleteError = deleteError {
                            observer.onError(deleteError)
                        } else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
}
