//
//  AuthService.swift
//  Routory
//
//  Created by 양원식 on 6/12/25.
//

import FirebaseAuth
import RxSwift

protocol AuthServiceProtocol {
    func deleteAccount() -> Observable<Void>
}

final class AuthService: AuthServiceProtocol {
    
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

}
