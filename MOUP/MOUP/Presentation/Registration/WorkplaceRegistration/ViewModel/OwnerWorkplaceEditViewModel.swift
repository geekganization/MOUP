//
//  OwnerWorkplaceEditViewModel.swift
//  Routory
//
//  Created by tlswo on 6/25/25.
//

import RxSwift
import RxCocoa

final class OwnerWorkplaceEditViewModel {
    
    struct Input {
        let updateTrigger: Observable<(
            workplaceId: String,
            name: String,
            category: String,
            uid: String,
            color: String
        )>
    }

    struct Output {
        let isLoading: Observable<Bool>
        let successMessage: Observable<String>
        let errorMessage: Observable<String>
    }

    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let loadingSubject = BehaviorSubject<Bool>(value: false)
    private let successSubject = PublishSubject<String>()
    private let errorSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }

    func transform(input: Input) -> Output {
        input.updateTrigger
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(true) })
            .flatMapLatest { [weak self] params -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return self.workplaceUseCase
                    .updateWorkplaceNameCategoryAndColor(
                        workplaceId: params.workplaceId,
                        name: params.name,
                        category: params.category,
                        uid: params.uid,
                        color: params.color
                    )
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                self?.loadingSubject.onNext(false)
                switch event {
                case .next:
                    self?.successSubject.onNext("근무지 정보가 수정되었습니다.")
                case .error(let error):
                    self?.errorSubject.onNext("수정 실패: \(error.localizedDescription)")
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)

        return Output(
            isLoading: loadingSubject.asObservable(),
            successMessage: successSubject.asObservable(),
            errorMessage: errorSubject.asObservable()
        )
    }
}
