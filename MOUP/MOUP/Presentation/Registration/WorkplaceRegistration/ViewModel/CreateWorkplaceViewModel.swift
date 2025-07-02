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
        let color: Observable<String>
        let role: Observable<Role>
    }
    
    struct Output {
        let workplaceId: Observable<String>
        let error: Observable<Error>
    }
    
    private let useCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    init(useCase: WorkplaceUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<Error>()
        let workplaceIdSubject = PublishSubject<String>()

        let combinedInput = Observable
            .combineLatest(input.workplace, input.workerDetail, input.uid, input.color, input.role)
        
        input.createTrigger
            .withLatestFrom(combinedInput)
            .flatMapLatest { [weak self] (workplace, workerDetail, uid, color, role) -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.useCase
                    .createWorkplaceWithCalendarAndMaybeWorker(uid: uid, role: role, workplace: workplace, workerDetail: workerDetail, color: color)
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
