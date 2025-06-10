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

enum Navigation {
    case goToMain
    case goToSignup
}

final class LoginViewModel {

    // MARK: - Input / Output

    struct Input {
        let googleLoginTapped: Observable<Void>
        let presentingVC: UIViewController
    }
    
    struct Output {
        let navigation: Observable<Navigation>
    }

    // MARK: - Dependencies

    private let googleAuthService: GoogleAuthServiceProtocol
    private let userService: UserServiceProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(googleAuthService: GoogleAuthServiceProtocol, userService: UserServiceProtocol) {
        self.googleAuthService = googleAuthService
        self.userService = userService
    }

    // MARK: - Transform

    func transform(input: Input) -> Output {
        let navigation = input.googleLoginTapped
            .flatMapLatest { [weak self] _ -> Observable<Navigation> in
                guard let self = self else { return .just(.goToSignup) }

                return self.googleAuthService.signInWithGoogle(presentingViewController: input.presentingVC)
                    .flatMapLatest { uid in
                        self.userService.checkUserExists(uid: uid)
                            .map { exists in
                                return exists ? .goToMain : .goToSignup
                            }
                    }
                    .catchAndReturn(.goToSignup)
            }
            .share()

        return Output(navigation: navigation)
    }
}
