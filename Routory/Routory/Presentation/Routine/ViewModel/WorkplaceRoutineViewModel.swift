//
//  WorkplaceRoutineViewModel.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import Foundation
import RxSwift
import RxRelay

final class WorkplaceRoutineViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let workplaceRoutine: TodaysRoutine
    private let routinesRelay = BehaviorRelay<[RoutineInfo]>(value: [])

    // MARK: - Initializer
    init(workplaceRoutine: TodaysRoutine) {
        self.workplaceRoutine = workplaceRoutine
        print("workplaceRoutineVM - \(workplaceRoutine)")
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: PublishRelay<Void>
    }

    struct Output {
        let workplaceTitle: Observable<String>
        let routines: Observable<[RoutineInfo]>
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.routinesRelay.accept(self.workplaceRoutine.routines)
            })
            .disposed(by: disposeBag)

        return Output(
            workplaceTitle: Observable.just(workplaceRoutine.workplaceName),
            routines: routinesRelay.asObservable()
        )
    }
}
