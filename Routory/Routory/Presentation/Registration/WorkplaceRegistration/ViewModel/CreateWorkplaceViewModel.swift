//
//  CreateWorkplaceViewModel.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import RxSwift
import RxCocoa

final class CreateWorkplaceViewModel {
    
    struct Input {
        let createTrigger: Observable<Void>
        let workplace: Observable<Workplace>
        let workerDetail: Observable<WorkerDetail>
        let uid: Observable<String>
    }
    
    struct Output {
        let workplaceId: Observable<String>
        let error: Observable<Error>
    }
    
    private let useCase: CreateWorkerWorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    init(useCase: CreateWorkerWorkplaceUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<Error>()
        let workplaceIdSubject = PublishSubject<String>()

        let combinedInput = Observable
            .combineLatest(input.workplace, input.workerDetail, input.uid)

        input.createTrigger
            .withLatestFrom(combinedInput)
            .flatMapLatest { [weak self] (workplace, workerDetail, uid) -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.useCase
                    .execute(workplace: workplace, workerDetail: workerDetail, uid: uid)
                    .catch { error in
                        errorSubject.onNext(error)
                        return .empty()
                    }
            }
            .bind(to: workplaceIdSubject)
            .disposed(by: disposeBag)
        
        return Output(
            workplaceId: workplaceIdSubject.asObservable(),
            error: errorSubject.asObservable()
        )
    }
}
