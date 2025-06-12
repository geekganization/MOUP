//
//  UserService.swift
//  Routory
//
//  Created by 서동환 on 6/6/25.
//

import Foundation
import FirebaseFirestore
import RxSwift
import FirebaseAuth

protocol UserServiceProtocol {
    func checkUserExists(uid: String) -> Observable<Bool>
    func createUser(user: User) -> Observable<Void>
    func deleteUser(uid: String) -> Observable<Void>
    func fetchUser(uid: String) -> Observable<User>
}

protocol AuthServiceProtocol {
    func deleteAccount() -> Observable<Void>
}


final class UserService: UserServiceProtocol, AuthServiceProtocol {
    private let db = Firestore.firestore()
    
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
    
    // MARK: - 회원가입
    func createUser(user: User) -> Observable<Void> {
        let data: [String: Any] = [
            "userName": user.userName,
            "role": user.role,
            "workplaceList": user.workplaceList
        ]
        return Observable.create { observer in
            self.db.collection("users").document(user.id).setData(data) { error in
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
    
    // MARK: - 회원 탈퇴 (삭제)
    func deleteUser(uid: String) -> Observable<Void> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).delete { error in
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
    /// Firebase Auth 계정 삭제 (회원탈퇴)
    func deleteAccount() -> Observable<Void> {
        return Observable.create { observer in
            guard let user = Auth.auth().currentUser else {
                observer.onError(NSError(domain: "NoUser", code: -1))
                return Disposables.create()
            }
            user.delete { error in
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
    
    // MARK: - 내 정보 조회
    func fetchUser(uid: String) -> Observable<User> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).getDocument { document, error in
                if let error = error {
                    observer.onError(error)
                } else if let document = document, let data = document.data() {
                    do {
                        // Firestore 데이터 → User 모델 디코딩
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
}
