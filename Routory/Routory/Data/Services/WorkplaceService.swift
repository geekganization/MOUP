//
//  WorkplaceService.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//

import FirebaseFirestore
import RxSwift

protocol WorkplaceServiceProtocol {
    func fetchWorkplaceByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?>
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void>
}


final class WorkplaceService: WorkplaceServiceProtocol {
    private let db = Firestore.firestore()
    
    /// 초대코드를 통해 근무지 정보를 조회합니다.
    ///
    /// - Parameter inviteCode: 조회할 근무지의 초대코드
    /// - Returns: 조회된 WorkplaceInfo(근무지 ID + 근무지 정보)를 방출하는 Observable, 없으면 nil
    /// - Firestore 경로: workplaces (inviteCode 검색)
    func fetchWorkplaceByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?> {
        return Observable.create { observer in
            self.db.collection("workplaces")
                .whereField("inviteCode", isEqualTo: inviteCode)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    guard let document = snapshot?.documents.first else {
                        observer.onNext(nil)
                        observer.onCompleted()
                        return
                    }
                    let data = document.data()
                    if let jsonData = try? JSONSerialization.data(withJSONObject: data),
                       let workplace = try? JSONDecoder().decode(Workplace.self, from: jsonData) {
                        let id = document.documentID
                        observer.onNext(WorkplaceInfo(id: id, workplace: workplace))
                    } else {
                        observer.onNext(nil)
                    }
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    /// 근무지의 worker 서브컬렉션에 알바(워커) 정보를 등록합니다.
    ///
    /// - Parameters:
    ///   - workplaceId: 근무지의 Firestore documentID
    ///   - uid: 등록할 알바(유저) UID
    ///   - workerDetail: 등록할 WorkerDetail 정보
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: workplaces/{workplaceId}/worker/{uid}
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void> {
        let db = Firestore.firestore()
        return Observable.create { observer in
            do {
                let data = try Firestore.Encoder().encode(workerDetail)
                db.collection("workplaces").document(workplaceId)
                    .collection("worker").document(uid)
                    .setData(data) { error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    }
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}
