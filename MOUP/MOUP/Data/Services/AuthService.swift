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
    
    private let disposeBag = DisposeBag()
    
    private let appleAuthService = AppleAuthService()
    
    /// Firebase Auth 계정 삭제 (회원탈퇴)
    func deleteAccount() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self, let user = Auth.auth().currentUser else {
                observer.onError(NSError(domain: "NoUser", code: -1))
                return Disposables.create()
            }
            let providers = user.providerData.map { $0.providerID }
            if providers.contains("apple.com") {
                appleAuthService.deleteCurrentUser()
                    .subscribe(with: self) { owner, _ in
                        user.delete { error in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                observer.onNext(())
                                observer.onCompleted()
                            }
                        }
                    }.disposed(by: disposeBag)
            } else {
                user.delete { error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(())
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }

}
