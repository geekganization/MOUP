//
//  WorkerListViewModel.swift
//  Routory
//
//  Created by tlswo on 6/25/25.
//

import RxSwift
import RxCocoa

final class WorkerListViewModel {

    struct Input {
        let deleteTrigger: Observable<(workplaceId: String, uid: String)>
        let fetchTrigger: Observable<String>
    }

    struct Output {
        let isLoading: Observable<Bool>
        let successMessage: Observable<String>
        let errorMessage: Observable<String>
        let workerList: Observable<[WorkerDetailInfo]>
    }

    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let loadingSubject = BehaviorSubject<Bool>(value: false)
    private let successSubject = PublishSubject<String>()
    private let errorSubject = PublishSubject<String>()
    private let workerListSubject = BehaviorSubject<[WorkerDetailInfo]>(value: [])

    private let disposeBag = DisposeBag()

    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }

    func transform(input: Input) -> Output {
        input.deleteTrigger
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(true) })
            .flatMapLatest { [weak self] params -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return self.workplaceUseCase
                    .deleteOrLeaveWorkplace(workplaceId: params.workplaceId, uid: params.uid)
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                self?.loadingSubject.onNext(false)
                switch event {
                case .next:
                    self?.successSubject.onNext("알바생이 삭제되었습니다.")
                case .error(let error):
                    self?.errorSubject.onNext("삭제 실패: \(error.localizedDescription)")
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)

        input.fetchTrigger
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(true) })
            .flatMapLatest { [weak self] workplaceId -> Observable<Event<[WorkerDetailInfo]>> in
                guard let self else { return .empty() }
                return self.workplaceUseCase
                    .fetchWorkerListForWorkplace(workplaceId: workplaceId)
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                self?.loadingSubject.onNext(false)
                switch event {
                case .next(let list):
                    self?.workerListSubject.onNext(list)
                case .error(let error):
                    self?.errorSubject.onNext("목록 조회 실패: \(error.localizedDescription)")
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)

        return Output(
            isLoading: loadingSubject.asObservable(),
            successMessage: successSubject.asObservable(),
            errorMessage: errorSubject.asObservable(),
            workerList: workerListSubject.asObservable()
        )
    }
}
