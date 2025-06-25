//
//  WorkerWorkplaceRegistrationViewModel.swift
//  Routory
//
//  Created by tlswo on 6/25/25.
//

import Foundation
import RxSwift
import RxCocoa

final class WorkerWorkplaceRegistrationViewModel {
    
    // MARK: - Input
    struct Input {
        let workplaceId: Observable<String>
        let uid: Observable<String>
        let workerDetail: Observable<WorkerDetail>
        let updateTrigger: Observable<Void> // 버튼 탭 등
    }
    
    // MARK: - Output
    struct Output {
        let updateSuccess: Observable<Void>
        let updateError: Observable<Error>
    }
    
    // MARK: - Private
    private let useCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(useCase: WorkplaceUseCaseProtocol) {
        self.useCase = useCase
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let errorTracker = PublishSubject<Error>()
        let updateResult = PublishSubject<Void>()
        
        input.updateTrigger
            .withLatestFrom(Observable.combineLatest(input.workplaceId, input.uid, input.workerDetail))
            .flatMapLatest { [weak self] workplaceId, uid, detail -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.useCase
                    .updateWorkerDetail(workplaceId: workplaceId, uid: uid, workerDetail: detail)
                    .catch { error in
                        errorTracker.onNext(error)
                        return .empty()
                    }
            }
            .bind(to: updateResult)
            .disposed(by: disposeBag)
        
        return Output(
            updateSuccess: updateResult.asObservable(),
            updateError: errorTracker.asObservable()
        )
    }
}
