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
            self.db.collection("calendars")
                .whereField("workplaceId", isEqualTo: workplaceId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    let calendarId = snapshot?.documents.first?.documentID
                    observer.onNext(calendarId)
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
    
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
}
