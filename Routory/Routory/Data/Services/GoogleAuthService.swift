//
//  GoogleAuthService.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import RxSwift

protocol GoogleAuthServiceProtocol {
    func signInWithGoogle(presentingViewController: UIViewController) -> Observable<String>
}

final class GoogleAuthService: GoogleAuthServiceProtocol {

    func signInWithGoogle(presentingViewController: UIViewController) -> Observable<String> {
        return Observable.create { observer in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString as String?,
                    let accessToken = user.accessToken.tokenString as String?
                else {
                    observer.onError(NSError(domain: "GoogleAuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "인증 토큰 없음"]))
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let uid = result?.user.uid {
                        observer.onNext(uid)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "GoogleAuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 정보 없음"]))
                    }
                }
            }

            return Disposables.create()
        }
    }
}
