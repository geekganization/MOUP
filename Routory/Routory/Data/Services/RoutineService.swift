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
    
    /// 지정된 사용자의 모든 루틴을 조회합니다.
    ///
    /// - Parameter uid: 루틴을 조회할 사용자 UID
    /// - Returns: RoutineInfo(루틴ID+루틴정보) 배열을 방출하는 Observable
    /// - Firestore 경로: users/{userId}/routine
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).collection("routine")
                .getDocuments { snapshot, error in
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
        return Observable.create { observer in
            let routineRef = self.db.collection("users").document(uid).collection("routine").document(routineId)
            routineRef.delete { error in
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
            
            // 1. 내 근무지 ID + 이름 조회
            let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces")
            
            return Observable.create { observer in
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
                    
                    // 1-2. 이름까지 받아오기
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
                    
                    workplacesObs.flatMap { workplaces -> Observable<[(name: String, events: [CalendarEvent])]> in
                        // 2. 각 근무지의 캘린더ID 찾고 오늘 이벤트 조회
                        let eventQueries = workplaces.map { (id, name) in
                            Observable<[CalendarEvent]>.create { eventObs in
                                self.db.collection("calendars")
                                    .whereField("workplaceId", isEqualTo: id)
                                    .getDocuments { calSnap, _ in
                                        guard let calendarId = calSnap?.documents.first?.documentID else {
                                            eventObs.onNext([])
                                            eventObs.onCompleted()
                                            return
                                        }
                                        // 3. 오늘 이벤트 조회
                                        self.db.collection("calendars").document(calendarId)
                                            .collection("events")
                                            .whereField("year", isEqualTo: year)
                                            .whereField("month", isEqualTo: month)
                                            .whereField("day", isEqualTo: day)
                                            .getDocuments { evtSnap, _ in
                                                let events = evtSnap?.documents.compactMap { doc -> CalendarEvent? in
                                                    do {
                                                        let jsonData = try JSONSerialization.data(withJSONObject: doc.data())
                                                        return try JSONDecoder().decode(CalendarEvent.self, from: jsonData)
                                                    } catch {
                                                        return nil
                                                    }
                                                } ?? []
                                                // 4. 루틴 연결된 이벤트만 필터
                                                let routineEvents = events.filter { !$0.routineIds.isEmpty }
                                                eventObs.onNext(routineEvents)
                                                eventObs.onCompleted()
                                            }
                                    }
                                return Disposables.create()
                            }.map { (name: name, events: $0) }
                        }
                        return Observable.zip(eventQueries)
                    }
                    .subscribe(onNext: { namedEventList in
                        // 5. [근무지이름: [이벤트]] 형태로 반환
                        let grouped = Dictionary(uniqueKeysWithValues: namedEventList.map { ($0.name, $0.events) })
                        observer.onNext(grouped)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: DisposeBag())
                }
                return Disposables.create()
            }
        }
}
