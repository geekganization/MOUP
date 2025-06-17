//
//  TabBarViewModel.swift
//  Routory
//
//  Created by 송규섭 on 6/18/25.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseAuth

final class TabBarViewModel {
    // MARK: - Properties
    private let userUseCase = UserUseCase(userRepository: UserRepository(userService: UserService()))
    private let disposeBag = DisposeBag()

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }

    struct Output {
        let user: Observable<User>
    }

    func tranform(input: Input) -> Output {
        let user = input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<User> in
                guard let self, let userId = UserManager.shared.firebaseUid else {
                    return .empty()
                }
                return self.userUseCase.fetchUser(uid: userId)
            }
            .share(replay: 1, scope: .whileConnected)

        return Output(user: user)
    }
}
