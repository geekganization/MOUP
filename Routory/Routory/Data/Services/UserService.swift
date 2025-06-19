//
//  UserService.swift
//  Routory
//
//  Created by 서동환 on 6/6/25.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxCocoa

enum Role {
    case owner
    case worker
}

/// 사용자 정보 및 근무지 연동, 워커 등록 관련 기능을 제공합니다.
protocol UserServiceProtocol {
    func checkUserExists(uid: String) -> Observable<Bool>
    func createUser(uid: String, user: User) -> Observable<Void>
    func deleteUser(uid: String) -> Observable<Void>
    func fetchUser(uid: String) -> Observable<User>
    func updateUserName(uid: String, newUserName: String) -> Observable<Void>
    func createWorkplace(
        workplace: Workplace,
        role: Role,
        workerDetail: WorkerDetail?,
        uid: String
    ) -> Observable<String>
    func addWorkplaceToUser(uid: String, workplaceId: String) -> Observable<Void>
    func fetchUserNotRx(uid: String, completion: @escaping (Result<User, Error>) -> Void)
}

final class UserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    
    /// 사용자의 존재 여부를 확인합니다.
    ///
    /// - Parameter uid: 확인할 사용자 UID.
    /// - Returns: 사용자가 존재하면 true, 아니면 false를 방출하는 Observable.
    func checkUserExists(uid: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).getDocument { document, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(document?.exists == true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    /// 새로운 사용자를 생성(회원가입)합니다.
    ///
    /// - Parameters:
    ///   - uid: 사용자 UID.
    ///   - user: 생성할 사용자 정보.
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable.
    func createUser(uid: String, user: User) -> Observable<Void> {
        let data: [String: Any] = [
            "userName": user.userName,
            "role": user.role
        ]
        return Observable.create { observer in
            self.db.collection("users").document(uid).setData(data) { error in
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
    
    /// 사용자를 삭제(회원 탈퇴)합니다.
    ///
    /// - Parameter uid: 삭제할 사용자 UID.
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable.
    func deleteUser(uid: String) -> Observable<Void> {
        // 1. 내가 오너인 workplaces 조회
        let ownedWorkplacesObs = Observable<[String]>.create { observer in
            self.db.collection("workplaces").whereField("ownerId", isEqualTo: uid).getDocuments { snap, err in
                if let err = err {
                    observer.onError(err)
                    return
                }
                let ids = snap?.documents.map { $0.documentID } ?? []
                observer.onNext(ids)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
        // 2. 내가 워커로 참여한 workplaces 조회
        let joinedWorkplacesObs = Observable<[String]>.create { observer in
            self.db.collection("users").document(uid).collection("workplaces").getDocuments { snap, err in
                if let err = err {
                    observer.onError(err)
                    return
                }
                let ids = snap?.documents.map { $0.documentID } ?? []
                observer.onNext(ids)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
        return Observable.zip(ownedWorkplacesObs, joinedWorkplacesObs)
            .flatMap { (ownedWorkplaceIds, joinedWorkplaceIds) -> Observable<Void> in
                
                // 1. 오너 근무지 삭제
                let ownerDeletes = Observable.from(ownedWorkplaceIds)
                    .flatMap { workplaceId -> Observable<Void> in
                        Observable.create { observer in
                            self.db.collection("workplaces").document(workplaceId)
                                .collection("worker").getDocuments { snap, err in
                                    guard let snap = snap, err == nil else {
                                        observer.onError(err ?? NSError(domain: "", code: -1))
                                        return
                                    }
                                    let workerUids = snap.documents.map { $0.documentID }
                                    var batch = self.db.batch()
                                    var batchOps = 0
                                    batch.deleteDocument(self.db.collection("workplaces").document(workplaceId)); batchOps += 1
                                    for workerUid in workerUids {
                                        batch.deleteDocument(self.db.collection("users").document(workerUid).collection("workplaces").document(workplaceId)); batchOps += 1
                                        if batchOps >= 450 {
                                            batch.commit { _ in }
                                            batch = self.db.batch(); batchOps = 0
                                        }
                                    }
                                    self.db.collection("calendars").whereField("workplaceId", isEqualTo: workplaceId).getDocuments { calSnap, _ in
                                        if let calendarId = calSnap?.documents.first?.documentID {
                                            batch.deleteDocument(self.db.collection("calendars").document(calendarId)); batchOps += 1
                                            let eventsRef = self.db.collection("calendars").document(calendarId).collection("events")
                                            eventsRef.getDocuments { eventsSnap, _ in
                                                let eventDocs = eventsSnap?.documents ?? []
                                                let group = DispatchGroup()
                                                for (i, doc) in eventDocs.enumerated() {
                                                    group.enter()
                                                    doc.reference.delete { _ in group.leave() }
                                                    if (i+1) % 450 == 0 {
                                                        batch.commit { _ in }
                                                        batch = self.db.batch(); batchOps = 0
                                                    }
                                                }
                                                batch.commit { error in
                                                    if let error = error {
                                                        observer.onError(error)
                                                    } else {
                                                        group.notify(queue: .main) {
                                                            observer.onNext(())
                                                            observer.onCompleted()
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            batch.commit { error in
                                                if let error = error {
                                                    observer.onError(error)
                                                } else {
                                                    observer.onNext(())
                                                    observer.onCompleted()
                                                }
                                            }
                                        }
                                    }
                                }
                            return Disposables.create()
                        }
                    }
                
                // 2. 내가 워커로만 참여한 근무지 처리
                let notOwnerWorkplaceIds = joinedWorkplaceIds.filter { !ownedWorkplaceIds.contains($0) }
                let workerDeletes = Observable.from(notOwnerWorkplaceIds)
                    .flatMap { workplaceId -> Observable<Void> in
                        Observable.create { observer in
                            var batch = self.db.batch()
                            var batchOps = 0
                            batch.deleteDocument(self.db.collection("workplaces").document(workplaceId).collection("worker").document(uid)); batchOps += 1
                            batch.deleteDocument(self.db.collection("users").document(uid).collection("workplaces").document(workplaceId)); batchOps += 1
                            self.db.collection("calendars").whereField("workplaceId", isEqualTo: workplaceId).getDocuments { calSnap, _ in
                                if let calendarId = calSnap?.documents.first?.documentID {
                                    let eventsRef = self.db.collection("calendars").document(calendarId).collection("events")
                                    eventsRef.whereField("createdBy", isEqualTo: uid).getDocuments { eventsSnap, _ in
                                        let eventDocs = eventsSnap?.documents ?? []
                                        let group = DispatchGroup()
                                        for (i, doc) in eventDocs.enumerated() {
                                            group.enter()
                                            doc.reference.delete { _ in group.leave() }
                                            if (i+1) % 450 == 0 {
                                                batch.commit { _ in }
                                                batch = self.db.batch(); batchOps = 0
                                            }
                                        }
                                        batch.commit { error in
                                            if let error = error {
                                                observer.onError(error)
                                            } else {
                                                group.notify(queue: .main) {
                                                    observer.onNext(())
                                                    observer.onCompleted()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    batch.commit { error in
                                        if let error = error {
                                            observer.onError(error)
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
                
                // 3. 내 users/{uid} 및 모든 서브컬렉션 삭제 (최후)
                let userDelete = Observable<Void>.create { observer in
                    let userRef = self.db.collection("users").document(uid)
                    userRef.collection("workplaces").getDocuments { snap, _ in
                        let group = DispatchGroup()
                        for doc in snap?.documents ?? [] {
                            group.enter()
                            doc.reference.delete { _ in group.leave() }
                        }
                        group.notify(queue: .main) {
                            userRef.delete { error in
                                if let error = error {
                                    observer.onError(error)
                                } else {
                                    observer.onNext(())
                                    observer.onCompleted()
                                }
                            }
                        }
                    }
                    return Disposables.create()
                }
                
                // 전체 삭제 순서대로 실행
                return Observable.concat(ownerDeletes, workerDeletes, userDelete)
                    .ignoreElements()
                    .asObservable()
                    .flatMap { _ in Observable.just(()) }
                    .ifEmpty(switchTo: Observable.just(()))
            }
    }

    
    /// 사용자 정보를 조회합니다.
    ///
    /// - Parameter uid: 조회할 사용자 UID.
    /// - Returns: 조회된 User 모델을 방출하는 Observable.
    func fetchUser(uid: String) -> Observable<User> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).getDocument { document, error in
                if let error = error {
                    observer.onError(error)
                } else if let document = document, let data = document.data() {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        observer.onNext(user)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                } else {
                    observer.onError(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchUserNotRx(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, let data = document.data() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let notFoundError = NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                completion(.failure(notFoundError))
            }
        }
    }
    
    /// 사용자의 닉네임을 변경합니다.
    ///
    /// - Parameters:
    ///   - uid: 사용자 UID.
    ///   - newUserName: 변경할 닉네임.
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable.
    func updateUserName(uid: String, newUserName: String) -> Observable<Void> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).updateData([
                "userName": newUserName
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
    
    /// 근무지를 생성하고(자동 ID 할당), 역할에 따라 worker 정보까지 함께 등록합니다.
    ///
    /// - Parameters:
    ///   - workplace: 생성할 근무지 정보.
    ///   - role: 생성자 역할(오너/알바).
    ///   - workerDetail: 알바(워커) 정보. 역할이 알바일 때만 필요.
    ///   - uid: 사용자 UID.
    /// - Returns: 생성된 근무지의 workplaceId를 방출하는 Observable.
    func createWorkplace(
        workplace: Workplace,
        role: Role,
        workerDetail: WorkerDetail?,
        uid: String
    ) -> Observable<String> {
        let workplaceRef = db.collection("workplaces").document()
        let workplaceId = workplaceRef.documentID
        
        return Observable.create { observer in
            let batch = self.db.batch()
            // 1. 근무지 문서
            batch.setData([
                "workplacesName": workplace.workplacesName,
                "category": workplace.category,
                "ownerId": workplace.ownerId,
                "inviteCode": workplace.inviteCode,
                "isOfficial": role == .owner ? true : false
            ], forDocument: workplaceRef)
            
            // 2. 알바라면 worker 서브컬렉션
            if role == .worker, let workerDetail = workerDetail {
                let workerRef = workplaceRef.collection("worker").document(uid)
                let workerData: [String: Any] = [
                    "workerName": workerDetail.workerName,
                    "wage": workerDetail.wage,
                    "wageCalcMethod": workerDetail.wageCalcMethod,
                    "wageType": workerDetail.wageType,
                    "weeklyAllowance": workerDetail.weeklyAllowance,
                    "payDay": workerDetail.payDay,
                    "payWeekday": workerDetail.payWeekday,
                    "breakTimeMinutes": workerDetail.breakTimeMinutes,
                    "employmentInsurance": workerDetail.employmentInsurance,
                    "healthInsurance": workerDetail.healthInsurance,
                    "industrialAccident": workerDetail.industrialAccident,
                    "nationalPension": workerDetail.nationalPension,
                    "incomeTax": workerDetail.incomeTax,
                    "nightAllowance": workerDetail.nightAllowance
                ]
                batch.setData(workerData, forDocument: workerRef)
            }
            
            // 3. batch 커밋
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
    
    /// 내 근무지 리스트(users/{userId}/workplaces/{workplaceId})에 빈 문서를 생성합니다.
    ///
    /// - Parameters:
    ///   - uid: 사용자 UID.
    ///   - workplaceId: 연동할 근무지 ID.
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable.
    func addWorkplaceToUser(uid: String, workplaceId: String) -> Observable<Void> {
        return Observable.create { observer in
            self.db.collection("users").document(uid)
                .collection("workplaces").document(workplaceId)
                .setData([:]) { error in
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

