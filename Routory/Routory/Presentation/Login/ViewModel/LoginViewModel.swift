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
    private let appleAuthService: AppleAuthServiceProtocol
    private let userService: UserServiceProtocol
    private let disposeBag = DisposeBag()
    
    private var currentNonce: String?
    
    // MARK: - Init
    
    init(appleAuthService: AppleAuthService, googleAuthService: GoogleAuthServiceProtocol, userService: UserServiceProtocol) {
        self.appleAuthService = appleAuthService
        self.googleAuthService = googleAuthService
        self.userService = userService
    }
    
    // MARK: - Transform
    
    
    func firebaseSignIn(with credential: AuthCredential) -> Observable<String> {
        return Observable.create { observer in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    observer.onError(error)
                } else if let uid = result?.user.uid {
                    observer.onNext(uid)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "Login", code: -1, userInfo: [NSLocalizedDescriptionKey: "No UID"]))
                }
            }
            return Disposables.create()
        }
    }
    
    func transform(input: Input) -> Output {
        let appleSignInNav = input.appleLoginTapped
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.appleAuthService.getAppleCredential()
                    .flatMapLatest { (username, credential) in
                        owner.firebaseSignIn(with: credential)
                            .flatMapLatest { uid in
                                owner.userService.fetchUser(uid: uid)
                                    .map { _ in Navigation.goToMain }
                                    .catch { _ in Observable.just(.goToSignup(username: username, credential: credential)) }
                            }
                    }
                    .catch { error in
                        owner.logger.error("애플 로그인 에러: \(error.localizedDescription)")
                        return Observable.empty()
                    }
            }
            .share()
        
        let googleSignInNav = input.googleLoginTapped
            .flatMapLatest { [weak self] _ in
                guard let self = self else { return Observable<Navigation>.empty() }
                return self.googleAuthService.getGoogleCredential(presentingViewController: input.presentingVC)
                    .flatMapLatest { (username, credential) in
                        self.firebaseSignIn(with: credential)
                            .flatMapLatest { uid in
                                self.userService.fetchUser(uid: uid)
                                    .map { _ in Navigation.goToMain }
                                    .catch { _ in Observable.just(.goToSignup(username: username, credential: credential)) }
                            }
                    }
                    .catch { error in
                        print("구글 로그인 에러: \(error)")
                        return Observable.empty()
                    }
            }
            .share()
        
        let navigation = Observable.merge(appleSignInNav, googleSignInNav)
        
        return Output(navigation: navigation)
    }
}
