//
//  ManageRoutineViewModel.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import Foundation
import RxSwift
import RxRelay

final class ManageRoutineViewModel {
    // MARK: - Properties
    private let userId: String
    private let disposeBag = DisposeBag()
    private lazy var todaysRoutineRelay = BehaviorRelay<[DummyTodaysRoutine]>(value: [])
    private lazy var allRoutineRelay = BehaviorRelay<[RoutineInfo]>(value: [])

    // MARK: - Mock Data
    private let mockTodaysRoutine = [
        DummyTodaysRoutine(workplaceName: "맥도날드", routines: [
            RoutineInfo(id: "4", routine: Routine(routineName: "청소", alarmTime: "14:00", tasks: ["매장 청소"]))
        ]),
        DummyTodaysRoutine(workplaceName: "세븐일레븐", routines: []),
        DummyTodaysRoutine(workplaceName: "GS25", routines: [
            RoutineInfo(id: "5", routine: Routine(routineName: "청소", alarmTime: "14:00", tasks: ["매장 청소"])),
            RoutineInfo(id: "6", routine: Routine(routineName: "유통기한 검수", alarmTime: "13:30", tasks: ["pp 매대", "치킨 매대"]))
        ])
    ]

    private let mockAllRoutine = [
        RoutineInfo(id: "1", routine: Routine(routineName: "오픈", alarmTime: "09:00", tasks: [])),
        RoutineInfo(id: "2", routine: Routine(routineName: "폐기", alarmTime: "13:30", tasks: [])),
        RoutineInfo(id: "3", routine: Routine(routineName: "청소", alarmTime: "14:30", tasks: []))
    ]

    // MARK: - Initializer
    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: PublishRelay<Void>
    }

    struct Output {
        let todaysRoutine: Observable<[DummyTodaysRoutine]>
        let allRoutine: Observable<[RoutineInfo]>
    }

    func transform(input: Input) -> Output {
        print("transform - ManageVC")
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.todaysRoutineRelay.accept(mockTodaysRoutine)
                self.allRoutineRelay.accept(mockAllRoutine)
            })
            .disposed(by: disposeBag)

        return Output(
            todaysRoutine: todaysRoutineRelay.asObservable(),
            allRoutine: allRoutineRelay.asObservable()
        )
    }

}
