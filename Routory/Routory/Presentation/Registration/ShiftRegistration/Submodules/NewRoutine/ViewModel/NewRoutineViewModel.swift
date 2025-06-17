//
//  NewRoutineViewModel.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class NewRoutineViewModel {

    struct Input {
        let saveTrigger: Observable<Routine>
    }

    struct Output {
        let didCreateRoutine: Observable<Void>
        let errorMessage: Observable<String>
    }

    private let useCase: RoutineUseCaseProtocol
    private let uid: String
    private let disposeBag = DisposeBag()

    private let didCreateRoutineRelay = PublishRelay<Void>()
    private let errorMessageRelay = PublishRelay<String>()

    init(useCase: RoutineUseCaseProtocol, uid: String) {
        self.useCase = useCase
        self.uid = uid
    }

    func transform(input: Input) -> Output {
        input.saveTrigger
            .flatMapLatest { [weak self] routine -> Observable<Event<Void>> in
                guard let self = self else { return .empty() }
                return self.useCase.createRoutine(uid: self.uid, routine: routine)
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    self?.didCreateRoutineRelay.accept(())
                case .error(let error):
                    self?.errorMessageRelay.accept("루틴 생성 실패: \(error.localizedDescription)")
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)

        return Output(
            didCreateRoutine: didCreateRoutineRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
}
