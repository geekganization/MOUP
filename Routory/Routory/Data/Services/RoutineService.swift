//
//  RoutineService.swift
//  Routory
//
//  Created by 양원식 on 6/13/25.
//

import RxSwift
import Foundation
import FirebaseFirestore

protocol RoutineServiceProtocol {
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]>
    func createRoutine(uid: String, routine: Routine) -> Observable<Void>
    func deleteRoutine(uid: String, routineId: String) -> Observable<Void>
    func updateRoutine(uid: String, routineId: String, routine: Routine) -> Observable<Void>
    func fetchTodayRoutineEventsGroupedByWorkplace(uid: String, date: Date) -> Observable<[String: [CalendarEvent]]>
}

final class RoutineService: RoutineServiceProtocol {
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()
    
    /// 지정된 사용자의 모든 루틴을 조회합니다.
    ///
    /// - Parameter uid: 루틴을 조회할 사용자 UID
    /// - Returns: RoutineInfo(루틴ID+루틴정보) 배열을 방출하는 Observable
    /// - Firestore 경로: users/{userId}/routine
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).collection("routine")
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    
                    let routines: [RoutineInfo] = documents.compactMap { doc in
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: doc.data())
                            let routine = try JSONDecoder().decode(Routine.self, from: jsonData)
                            return RoutineInfo(id: doc.documentID, routine: routine)
                        } catch {
                            print("루틴 디코딩 실패: \(error)")
                            return nil
                        }
                    }
                    
                    observer.onNext(routines)
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    /// 사용자의 루틴을 새로 등록합니다.
    ///
    /// - Parameters:
    ///   - uid: 루틴을 등록할 사용자 UID
    ///   - routine: 등록할 Routine 모델
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: users/{userId}/routine/{autoId}
    func createRoutine(uid: String, routine: Routine) -> Observable<Void> {
        return Observable.create { observer in
            
            let routineRef = self.db.collection("users").document(uid).collection("routine").document()
            let routineId = routineRef.documentID
            
            let data: [String: Any] = [
                "routineName": routine.routineName,
                "alarmTime": routine.alarmTime,
                "tasks": routine.tasks
            ]
            
            routineRef.setData(data) { error in
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
    
    /// 사용자의 특정 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - uid: 루틴을 삭제할 사용자 UID
    ///   - routineId: 삭제할 루틴의 ID
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: users/{userId}/routine/{routineId}
    func deleteRoutine(uid: String, routineId: String) -> Observable<Void> {
        let db = self.db
        
        // 1. 내가 오너인 캘린더 id들 조회
        let ownerCalendarsObs = Observable<[String]>.create { observer in
            db.collection("calendars").whereField("ownerId", isEqualTo: uid).getDocuments { snap, err in
                if let err = err {
                    observer.onError(err)
                    return
                }
                let calendarIds = snap?.documents.map { $0.documentID } ?? []
                observer.onNext(calendarIds)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
        // 2. 쉐어윗에 내가 들어간 캘린더 id들 조회
        let sharedCalendarsObs = Observable<[String]>.create { observer in
            db.collection("calendars").whereField("shareWith", arrayContains: uid).getDocuments { snap, err in
                if let err = err {
                    observer.onError(err)
                    return
                }
                let calendarIds = snap?.documents.map { $0.documentID } ?? []
                observer.onNext(calendarIds)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
        // 3. 두 결과 합치기
        return Observable.zip(ownerCalendarsObs, sharedCalendarsObs)
            .flatMap { (ownerIds, sharedIds) -> Observable<Void> in
                let calendarIds = Set(ownerIds).union(sharedIds) // 중복 제거
                
                // 4. 각 캘린더에서, 이벤트 컬렉션을 순회하며 내가 만든 이벤트 중 routineId == 삭제할 routineId인 것의 routineId 필드를 삭제
                let eventsUpdates = calendarIds.map { calendarId in
                    Observable<Void>.create { observer in
                        let eventsRef = db.collection("calendars").document(calendarId).collection("events")
                        eventsRef
                            .whereField("createdBy", isEqualTo: uid)
                            .whereField("routineId", isEqualTo: routineId)
                            .getDocuments { snap, err in
                                if let err = err {
                                    observer.onError(err)
                                    return
                                }
                                let docs = snap?.documents ?? []
                                if docs.isEmpty {
                                    observer.onNext(())
                                    observer.onCompleted()
                                    return
                                }
                                let group = DispatchGroup()
                                for doc in docs {
                                    group.enter()
                                    doc.reference.updateData(["routineId": FieldValue.delete()]) { _ in
                                        group.leave()
                                    }
                                }
                                group.notify(queue: .main) {
                                    observer.onNext(())
                                    observer.onCompleted()
                                }
                            }
                        return Disposables.create()
                    }
                }
                // 5. 모든 이벤트 업데이트가 끝나면 완료
                return Observable.zip(eventsUpdates)
                    .map { _ in () }
            }
    }
    
    /// 사용자의 특정 루틴 정보를 수정합니다.
    ///
    /// - Parameters:
    ///   - uid: 루틴을 수정할 사용자 UID
    ///   - routineId: 수정할 루틴의 ID
    ///   - routine: 수정할 Routine 모델
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: users/{userId}/routine/{routineId}
    func updateRoutine(uid: String, routineId: String, routine: Routine) -> Observable<Void> {
        return Observable.create { observer in
            let routineRef = self.db.collection("users").document(uid).collection("routine").document(routineId)
            let data: [String: Any] = [
                "routineName": routine.routineName,
                "alarmTime": routine.alarmTime,
                "tasks": routine.tasks
            ]
            routineRef.updateData(data) { error in
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
    
    func fetchTodayRoutineEventsGroupedByWorkplace(uid: String, date: Date) -> Observable<[String: [CalendarEvent]]> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces")

        return Observable.create { observer in
            // 전체 해제 함수 저장용
            var listenerRemovers: [() -> Void] = []

            userWorkplaceRef.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let workplaceIds = snapshot?.documents.map { $0.documentID } ?? []
                if workplaceIds.isEmpty {
                    observer.onNext([:])
                    observer.onCompleted()
                    return
                }

                // 1. 근무지 id별로 이름 조회
                let workplacesObs = Observable.zip(workplaceIds.map { workplaceId in
                    Observable<(id: String, name: String)>.create { nameObs in
                        self.db.collection("workplaces").document(workplaceId).getDocument { doc, _ in
                            if let doc = doc, let data = doc.data(),
                               let name = data["workplacesName"] as? String {
                                nameObs.onNext((id: workplaceId, name: name))
                            }
                            nameObs.onCompleted()
                        }
                        return Disposables.create()
                    }
                })

                workplacesObs.subscribe(onNext: { workplaces in
                    // 2. 각 근무지별로 오늘 이벤트를 리스너 방식으로 감시
                    var workplaceNameList: [String] = workplaces.map { $0.name }
                    var eventMap: [String: [CalendarEvent]] = Dictionary(uniqueKeysWithValues: workplaceNameList.map { ($0, []) })

                    // 근무지별 리스너 등록
                    for (workplaceId, name) in workplaces {
                        self.db.collection("calendars")
                            .whereField("workplaceId", isEqualTo: workplaceId)
                            .getDocuments { calSnap, _ in
                                guard let calendarId = calSnap?.documents.first?.documentID else {
                                    // 캘린더 없으면 해당 근무지는 빈 배열 유지
                                    observer.onNext(eventMap)
                                    return
                                }

                                let listener = self.db.collection("calendars").document(calendarId)
                                    .collection("events")
                                    .whereField("year", isEqualTo: year)
                                    .whereField("month", isEqualTo: month)
                                    .whereField("day", isEqualTo: day)
                                    .addSnapshotListener { evtSnap, _ in
                                        let events = evtSnap?.documents.compactMap { doc -> CalendarEvent? in
                                            do {
                                                let jsonData = try JSONSerialization.data(withJSONObject: doc.data())
                                                return try JSONDecoder().decode(CalendarEvent.self, from: jsonData)
                                            } catch {
                                                return nil
                                            }
                                        } ?? []
                                        let routineEvents = events.filter { !$0.routineIds.isEmpty }
                                        eventMap[name] = routineEvents
                                        observer.onNext(eventMap)
                                    }
                                // 리스너 해제를 위한 remover 저장
                                listenerRemovers.append {
                                    listener.remove()
                                }
                            }
                    }
                }, onError: { error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            }

            // 모든 리스너를 해제하는 disposer 반환
            return Disposables.create {
                listenerRemovers.forEach { $0() }
            }
        }
    }

}
