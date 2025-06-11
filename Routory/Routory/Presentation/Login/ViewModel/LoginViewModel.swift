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
    case goToSignup(googleUid: String, googleNickname: String)
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
                guard let self = self else { return .just(.goToMain) }

                // 구글 로그인 → uid, nickname
                return self.googleAuthService.signInWithGoogle(presentingViewController: input.presentingVC)
                    .flatMapLatest { (uid, nickname) in
                        // Firestore에서 해당 uid의 유저 존재 여부 체크
                        self.userService.checkUserExists(uid: uid)
                            .map { exists in
                                if exists {
                                    print("기존 유저 → 메인으로 이동")
                                    return .goToMain
                                } else {
                                    print("신규 유저 → 회원가입으로 이동")
                                    return .goToSignup(googleUid: uid, googleNickname: nickname)
                                }
                            }
                            // Firestore 읽기 에러 발생 시 → 회원가입 화면으로 이동
                            .catchAndReturn(.goToSignup(googleUid: uid, googleNickname: nickname))
                    }
                    // 구글 로그인 자체가 실패하면 아무것도 안함
                    .catch { error in
                        print("구글 로그인 에러: \(error)")
                        return Observable.empty()
                    }
            }
            .share()

        return Output(navigation: navigation)
    }

}
