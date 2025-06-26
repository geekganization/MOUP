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
    func signInWithGoogle(presentingViewController: UIViewController) -> Observable<(String, String, AuthCredential)>
    func getGoogleCredential(presentingViewController: UIViewController) -> Observable<(String, AuthCredential)>
}

final class GoogleAuthService: GoogleAuthServiceProtocol {
    func signInWithGoogle(presentingViewController: UIViewController) -> Observable<(String, String, AuthCredential)> {
        return Observable.create { observer in
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
                observer.onNext((idToken, accessToken, credential))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func getGoogleCredential(presentingViewController: UIViewController) -> Observable<(String, AuthCredential)> {
        return Observable.create { observer in
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
                let username = user.profile?.name ?? "닉네임없음"
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    observer.onNext((username, credential))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
