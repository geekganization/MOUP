//
//  LoginViewModel.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import FirebaseAuth

enum Navigation {
    case goToMain
    case goToSignup(username: String, credential: AuthCredential)
}

final class LoginViewModel {

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

    private let appleAuthService: AppleAuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    private let userService: UserServiceProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(appleAuthService: AppleAuthServiceProtocol, googleAuthService: GoogleAuthServiceProtocol, userService: UserServiceProtocol) {
        self.appleAuthService = appleAuthService
        self.googleAuthService = googleAuthService
        self.userService = userService
    }

    // MARK: - Transform

    func transform(input: Input) -> Output {
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
