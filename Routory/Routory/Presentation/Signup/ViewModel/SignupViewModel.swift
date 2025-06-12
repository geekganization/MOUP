//
//  SignupViewModel.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import RxSwift
import RxCocoa

final class SignupViewModel {
    struct Input {
        let roleSelected: Observable<String>
        let confirmTapped: Observable<Void>
    }
    struct Output {
        let signupSuccess: Observable<Void>
        let signupError: Observable<Error>
    }
    
    // 의존성
    private let userUseCase: UserUseCaseProtocol
    private let userId: String // 구글 로그인된 uid
    private let userName: String // 구글 닉네임
    private let disposeBag = DisposeBag()
    
    // 상태 저장
    private let selectedRoleRelay = BehaviorRelay<String?>(value: nil)
    
    init(userUseCase: UserUseCaseProtocol, userId: String, userName: String) {
        self.userUseCase = userUseCase
        self.userId = userId
        self.userName = userName
    }
    
    func transform(input: Input) -> Output {
        // 역할 저장
        input.roleSelected
            .bind(to: selectedRoleRelay)
            .disposed(by: disposeBag)
        
        let result = input.confirmTapped
            .withLatestFrom(selectedRoleRelay.compactMap { $0 })
            .flatMapLatest { [weak self] role -> Observable<Event<Void>> in
                guard let self = self else { return .empty() }
                let user = User(userName: self.userName, role: role, workplaceList: [])
                return self.userUseCase.createUser(uid: self.userId, user: user)
                    .materialize()
            }
            .share()
        
        let signupSuccess = result
            .compactMap { $0.element }
        let signupError = result
            .compactMap { $0.error }
        
        return Output(
            signupSuccess: signupSuccess,
            signupError: signupError
        )
    }
}
