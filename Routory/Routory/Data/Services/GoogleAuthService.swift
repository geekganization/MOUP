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
    func signInWithGoogle(presentingViewController: UIViewController) -> Observable<(String, String)>
}

final class GoogleAuthService: GoogleAuthServiceProtocol {
    func signInWithGoogle(presentingViewController: UIViewController) -> Observable<(String, String)> {
        return Observable.create { observer in
            // clientID 필요없음! (Firebase 연동 시 내부적으로 처리)
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard
                    let user = signInResult?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    observer.onError(NSError(domain: "GoogleAuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "인증 토큰 없음"]))
                    return
                }
                let accessToken = user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let user = result?.user {
                        let uid = user.uid
                        let nickname = user.displayName ?? "닉네임없음"
                        observer.onNext((uid, nickname))
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
