//
//  EmployeeSelectionViewModel.swift
//  Routory
//
//  Created by tlswo on 6/19/25.
//

import Foundation
import RxSwift
import RxCocoa

final class EmployeeSelectionViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let workplaceId: Observable<String>
    }

    struct Output {
        let workerList: Observable<[WorkerDetailInfo]>
        let error: Observable<Error>
    }

    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }

    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<Error>()
        let workerListSubject = PublishSubject<[WorkerDetailInfo]>()

        let workplaceIdRelay = BehaviorRelay<String?>(value: nil)

        input.workplaceId
            .bind(to: workplaceIdRelay)
            .disposed(by: disposeBag)

        input.viewDidLoad
            .withLatestFrom(workplaceIdRelay.compactMap { $0 })
            .flatMapLatest { [weak self] id -> Observable<[WorkerDetailInfo]> in
                guard let self = self else { return .empty() }
                return self.workplaceUseCase.fetchWorkerListForWorkplace(workplaceId: id)
                    .catch { error in
                        errorSubject.onNext(error)
                        return .just([])
                    }
            }
            .bind(to: workerListSubject)
            .disposed(by: disposeBag)

        return Output(
            workerList: workerListSubject.asObservable(),
            error: errorSubject.asObservable()
        )
    }
}
