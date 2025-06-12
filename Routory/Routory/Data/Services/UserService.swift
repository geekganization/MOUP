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
    func createUser(user: User) -> Observable<Void>
    func deleteUser(uid: String) -> Observable<Void>
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
}
