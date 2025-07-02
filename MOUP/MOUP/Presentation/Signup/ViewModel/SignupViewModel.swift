//
//  SignupViewModel.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import RxSwift
import RxCocoa
import FirebaseAuth

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
    private let credential: AuthCredential
    private let userName: String // 구글 닉네임
    private let disposeBag = DisposeBag()
    
    // 상태 저장
    private let selectedRoleRelay = BehaviorRelay<String?>(value: nil)
    
    init(userUseCase: UserUseCaseProtocol, credential: AuthCredential, userName: String) {
        self.userUseCase = userUseCase
        self.userName = userName
        self.credential = credential
    }
    
    func transform(input: Input) -> Output {
            input.roleSelected
                .bind(to: selectedRoleRelay)
                .disposed(by: disposeBag)
            
            let result = input.confirmTapped
                .withLatestFrom(selectedRoleRelay.compactMap { $0 })
                .flatMapLatest { [weak self] role -> Observable<Event<Void>> in
                    guard let self = self else { return .empty() }
                    return Observable.create { observer in
                        // Use the already signed-in Firebase user instead of signing in again
                        guard let uid = Auth.auth().currentUser?.uid else {
                            observer.onError(NSError(domain: "Signup", code: -1, userInfo: [NSLocalizedDescriptionKey: "Auth user not found"]))
                            return Disposables.create()
                        }
                        let userData = User(userName: self.userName, role: role, workplaceList: [])
                        self.userUseCase.createUser(uid: uid, user: userData)
                            .subscribe(
                                onNext: { observer.onNext(()) },
                                onError: { observer.onError($0) },
                                onCompleted: { observer.onCompleted() }
                            )
                            .disposed(by: self.disposeBag)
                        return Disposables.create()
                    }.materialize()
                }
                .share()
            
            let signupSuccess = result.compactMap { $0.element }
            let signupError = result.compactMap { $0.error }
            
            return Output(
                signupSuccess: signupSuccess,
                signupError: signupError
            )
        }
}
