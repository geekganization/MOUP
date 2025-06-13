//
//  UserService.swift
//  Routory
//
//  Created by 서동환 on 6/6/25.
//

import Foundation
import FirebaseFirestore
import RxSwift

protocol UserServiceProtocol {
    func checkUserExists(uid: String) -> Observable<Bool>
    func createUser(uid: String, user: User) -> Observable<Void>
    func deleteUser(uid: String) -> Observable<Void>
    func fetchUser(uid: String) -> Observable<(User)>
    func updateUserName(uid: String, newUserName: String) -> Observable<Void>
}

final class UserService: UserServiceProtocol {
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
    func createUser(uid: String, user: User) -> Observable<Void> {
        let data: [String: Any] = [
            "userName": user.userName,
            "role": user.role,
            "workplaceList": user.workplaceList
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
    
    // MARK: - 내 정보 조회
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
    
    // MARK: - 닉네임 변경
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

}
