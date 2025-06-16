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
}

final class RoutineService: RoutineServiceProtocol {
    private let db = Firestore.firestore()
    
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
    
    /// 루틴 등록 (루틴 ID 자동 생성, 성공 시 해당 ID 반환)
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
    
    /// 루틴 삭제
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
}
