//
//  LoginViewModel.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import Foundation
import AuthenticationServices
import CryptoKit
import OSLog
import RxSwift
import RxCocoa
import UIKit
import FirebaseAuth

enum Navigation {
    case goToMain
    case goToSignup(username: String, credential: AuthCredential)
}

final class LoginViewModel: NSObject {

    // MARK: - Input / Output

    struct Input {
        let appleLoginTapped: Observable<Void>
        let googleLoginTapped: Observable<Void>
        let presentingVC: UIViewController
    }
    
    struct Output {
        let navigation: Observable<Navigation>
    }

    // MARK: - Dependencies
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))

    private let googleAuthService: GoogleAuthServiceProtocol
    private let userService: UserServiceProtocol
    private let disposeBag = DisposeBag()
    
    private var currentNonce: String?

    // MARK: - Init

    init(googleAuthService: GoogleAuthServiceProtocol, userService: UserServiceProtocol) {
        self.googleAuthService = googleAuthService
        self.userService = userService
    }

    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.appleLoginTapped
            .subscribe(with: self) { owner, _ in
                let nonce = owner.randomNonceString()
                owner.currentNonce = nonce
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName]
                request.nonce = owner.sha256(nonce)
                
                let authController = ASAuthorizationController(authorizationRequests: [request])
                authController.delegate = self
                authController.performRequests()
            }.disposed(by: disposeBag)
        
        let navigation = input.googleLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<Navigation> in
                guard let self = self else { return .empty() }
                // 구글 OAuth → credential, nickname
                return self.googleAuthService.getGoogleCredential(presentingViewController: input.presentingVC)
                    .flatMapLatest { (username, credential) in
                        return Observable.just(.goToSignup(username: username, credential: credential))
                    }
                    .catch { error in
                        print("구글 로그인 에러: \(error)")
                        return Observable.empty()
                    }
            }
            .share()
        
        return Output(navigation: navigation)
    }
}

// MARK: - Apple SignIn Methods

private extension LoginViewModel {
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

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                logger.error("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                logger.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.logger.error("Error Apple sign in: \(error.localizedDescription)")
                    return
                }
                // 로그인에 성공했을 시 실행할 메서드 추가
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        logger.error("\(error.localizedDescription)")
    }
}
