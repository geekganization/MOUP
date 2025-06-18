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
    func createWorkplaceWithCalendarAndMaybeWorker(
            uid: String,
            role: Role,
            workplace: Workplace,
            workerDetail: WorkerDetail?,
            color: String
        ) -> Observable<String>
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]>
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
    
    /// 해당 사용자가 소속된 모든 근무지 정보를 조회합니다.
    /// - Parameter uid: 유저의 UID
    /// - Returns: WorkplaceInfo 배열
    /// - Firestore 경로: users/{uid}/workplaces → workplaces/{workplaceId}
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]> {
        let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces")
        return Observable.create { observer in
            userWorkplaceRef.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let ids = snapshot?.documents.map { $0.documentID } ?? []
                // 각 workplaceId로 workplaces 컬렉션에서 상세 조회 Observable 만들기
                let observables: [Observable<WorkplaceInfo>] = ids.map { workplaceId in
                    Observable<WorkplaceInfo>.create { detailObserver in
                        self.db.collection("workplaces").document(workplaceId).getDocument { doc, error in
                            if let doc = doc, let data = doc.data() {
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                                    let workplace = try JSONDecoder().decode(Workplace.self, from: jsonData)
                                    detailObserver.onNext(WorkplaceInfo(id: workplaceId, workplace: workplace))
                                    detailObserver.onCompleted()
                                } catch {
                                    detailObserver.onError(error)
                                }
                            } else {
                                detailObserver.onCompleted()
                            }
                        }
                        return Disposables.create()
                    }
                }
                // 모든 workplace 조회 결과를 [WorkplaceInfo]로 묶어서 반환
                Observable.zip(observables)
                    .subscribe(onNext: { workplaces in
                        observer.onNext(workplaces)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: DisposeBag())
            }
            return Disposables.create()
        }
    }
    
    /// 근무지, 캘린더를 동시에 생성(필요시 워커 등록)합니다.
    ///
    /// - Parameters:
    ///   - uid: 현재 유저의 UID (owner/worker)
    ///   - role: 사용자 역할(.owner 또는 .worker)
    ///   - workplace: 생성할 근무지 정보(Workplace)
    ///   - workerDetail: 알바(워커)라면 워커 정보, 아니면 nil
    ///   - color: 유저가 선택한 근무지 색상값
    /// - Returns: 생성된 workplaceId를 방출하는 Observable
    /// - Firestore 경로:
    ///     - workplaces/{workplaceId}
    ///     - calendars/{calendarId}
    ///     - users/{uid}/workplace/{workplaceId}
    ///     - workplaces/{workplaceId}/worker/{uid} (알바만)
    func createWorkplaceWithCalendarAndMaybeWorker(
        uid: String,
        role: Role,
        workplace: Workplace,
        workerDetail: WorkerDetail?,
        color: String
    ) -> Observable<String> {
        let workplaceRef = db.collection("workplaces").document()
        let workplaceId = workplaceRef.documentID
        let calendarRef = db.collection("calendars").document()
        let userWorkplaceRef = db.collection("users").document(uid).collection("workplace").document(workplaceId)
        
        return Observable.create { observer in
            let batch = self.db.batch()
            
            // 1. 근무지 저장
            batch.setData([
                "workplacesName": workplace.workplacesName,
                "category": workplace.category,
                "ownerId": workplace.ownerId,
                "inviteCode": workplace.inviteCode,
                "isOfficial": (role == .owner)
            ], forDocument: workplaceRef)
            
            // 2. 캘린더 저장 (조건에 맞게 필드 세팅)
            batch.setData([
                "calendarName": workplace.workplacesName,
                "isShared": (role == .owner),
                "ownerId": uid,
                "sharedWith": [],
                "workplaceId": workplaceId
            ], forDocument: calendarRef)
            
            // 3. 알바일 때 워커 서브컬렉션 등록
            if role == .worker, let workerDetail {
                let workerRef = workplaceRef.collection("worker").document(uid)
                do {
                    let workerData = try Firestore.Encoder().encode(workerDetail)
                    batch.setData(workerData, forDocument: workerRef)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
            }
            
            // 4. 사장이든 알바든 users/{uid}/workplace/{workplaceId}에 color 저장
            batch.setData([
                "color": color
            ], forDocument: userWorkplaceRef)
            
            batch.commit { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(workplaceId)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
