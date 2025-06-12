//
//  DeleteAccountViewModel.swift
//  Routory
//
//  Created by 양원식 on 6/12/25.
//

import RxSwift
import RxCocoa

final class DeleteAccountViewModel {
    struct Input { let confirmDeleteTapped: Observable<Void> }
    struct Output {
        let deleteCompleted: Observable<Void>
        let errorOccurred: Observable<Error>
        let isLoading: Observable<Bool>
    }
    
    private let userUseCase: UserUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let userId: String
    private let disposeBag = DisposeBag()
    
    private let deleteCompletedSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    
    init(
        userUseCase: UserUseCaseProtocol,
        authUseCase: AuthUseCaseProtocol,
        userId: String
    ) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.userId = userId
    }
    
    func transform(input: Input) -> Output {
        input.confirmDeleteTapped
            .do(onNext: { [weak self] _ in self?.isLoadingSubject.onNext(true) })
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.authUseCase.deleteAccount()
                    .flatMap { [weak self] _ -> Observable<Void> in
                        guard let self = self else { return .empty() }
                        return self.userUseCase.deleteUser(uid: self.userId)
                    }
                    .catch { [weak self] error in
                        self?.errorSubject.onNext(error)
                        self?.isLoadingSubject.onNext(false)
                        // TODO: View에서 errorOccurred 구독하여 Toast 메시지 띄우기
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] in
                self?.deleteCompletedSubject.onNext(())
                self?.isLoadingSubject.onNext(false)
            })
            .disposed(by: disposeBag)
        
        return Output(
            deleteCompleted: deleteCompletedSubject.asObservable(),
            errorOccurred: errorSubject.asObservable(),
            isLoading: isLoadingSubject.asObservable()
        )
    }
}
