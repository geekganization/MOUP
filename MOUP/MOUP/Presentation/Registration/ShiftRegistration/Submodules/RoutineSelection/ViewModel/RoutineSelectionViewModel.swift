//
//  RoutineSelectionViewModel.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import RxSwift
import RxCocoa

final class RoutineSelectionViewModel {

    struct Input {
        let fetchTrigger: Observable<Void>
    }

    struct Output {
        let routineItems: Observable<[RoutineItem]>
        let errorMessage: Observable<String>
    }

    private let useCase: RoutineUseCaseProtocol
    private let uid: String

    private let errorSubject = PublishSubject<String>()

    init(useCase: RoutineUseCaseProtocol, uid: String) {
        self.useCase = useCase
        self.uid = uid
    }

    func transform(input: Input) -> Output {
        let items = input.fetchTrigger
            .flatMapLatest { [weak self] _ -> Observable<[RoutineItem]> in
                guard let self else { return .just([]) }
                return self.useCase.fetchAllRoutines(uid: uid)
                    .map { $0.map { RoutineItem(routineInfo: $0, isSelected: false) } }
                    .catch { [weak self] error in
                        self?.errorSubject.onNext("루틴을 불러오는 데 실패했어요.")
                        return .just([])
                    }
            }
            .share(replay: 1)

        return Output(
            routineItems: items,
            errorMessage: errorSubject.asObservable()
        )
    }
}
