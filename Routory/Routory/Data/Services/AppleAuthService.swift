//
//  AppleAuthService.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation
import AuthenticationServices
import CryptoKit
import OSLog

import FirebaseAuth
import RxCocoa
import RxSwift

protocol AppleAuthServiceProtocol {
    func signInWithApple() -> Observable<(String, String, OAuthCredential)>
    func getAppleCredential() -> Observable<(String, OAuthCredential)>
}

final class AppleAuthService: NSObject, AppleAuthServiceProtocol {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let disposeBag = DisposeBag()
    
    private var currentNonce: String?
    
    // MARK: - AppleAuthServiceProtocol Methods
    
    func signInWithApple() -> Observable<(String, String, OAuthCredential)> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName]
            request.nonce = sha256(nonce)
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.performRequests()
            
            authController.rx.didCompleteWithAuthorization.asObservable()
                .subscribe(with: self) { owner, credential in
                    if let appleIDCredential = credential as? ASAuthorizationAppleIDCredential {
                        guard let nonce = owner.currentNonce else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let appleIDToken = appleIDCredential.identityToken else {
                            owner.logger.error("Unable to fetch identity token")
                            return
                        }
                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                            owner.logger.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                            return
                        }
                        // Initialize a Firebase credential, including the user's full name.
                        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
                        observer.onNext((idTokenString, nonce, credential))
                        observer.onCompleted()
                    }
                }.disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
    
    func getAppleCredential() -> Observable<(String, OAuthCredential)> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName]
            request.nonce = sha256(nonce)
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.performRequests()
            
            authController.rx.didCompleteWithAuthorization.asObservable()
                .subscribe(with: self) { owner, credential in
                    if let appleIDCredential = credential as? ASAuthorizationAppleIDCredential {
                        guard let nonce = owner.currentNonce else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let appleIDToken = appleIDCredential.identityToken else {
                            owner.logger.error("Unable to fetch identity token")
                            return
                        }
                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                            owner.logger.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                            return
                        }
                        // Initialize a Firebase credential, including the user's full name.
                        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
                        let username = appleIDCredential.fullName?.formatted() ?? "닉네임 없음"
                        
                        Auth.auth().signIn(with: credential) { authResult, error in
                            if let error = error {
                                observer.onError(error)
                                return
                            }
                            observer.onNext((username, credential))
                            observer.onCompleted()
                        }
                    }
                }.disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
}

// MARK: - Apple SignIn Methods

private extension AppleAuthService {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
