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
    private let workplaceRoutine: DummyTodaysRoutine
    private let routinesRelay = BehaviorRelay<[RoutineInfo]>(value: [])

    // MARK: - Initializer
    init(workplaceRoutine: DummyTodaysRoutine) {
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
            .do(onNext: {
                print("viewModel - viewDidLoad 이벤트 수신됨")
            })
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                print("viewDidLoad 호출됨")
                self.routinesRelay.accept(self.workplaceRoutine.routines)
            })
            .disposed(by: disposeBag)

        return Output(
            workplaceTitle: Observable.just(workplaceRoutine.workplaceName),
            routines: routinesRelay.asObservable()
        )
    }
}
