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
    private var userId: String? {
        return UserManager.shared.firebaseUid
    }
    private let routineType: RoutineType
    private let disposeBag = DisposeBag()
    private let routineUseCase: RoutineUseCaseProtocol

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
    init(type: RoutineType, routineUseCase: RoutineUseCaseProtocol) {
        self.routineType = type
        self.routineUseCase = routineUseCase
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }

    struct Output {
        let todaysRoutine: Observable<[DummyTodaysRoutine]>
        let allRoutine: Observable<[RoutineInfo]>
    }

    func transform(input: Input) -> Output {
        print("transform - ManageVC")
        print("현재 루틴 타입 - \(routineType)")
        switch routineType {
        case .today:
            print("오늘의 루틴 호출 시도")
            let todayRoutines = input.viewDidLoad
                .flatMapLatest { [weak self] _ -> Observable<[DummyTodaysRoutine]> in
                    print("flatMapLatest 진입")
                    guard let self else { print("self가 nil"); return .empty() }
                    return self.fetchTodayRoutines()
                }
                .share(replay: 1, scope: .whileConnected)

            return Output(
                todaysRoutine: todayRoutines,
                allRoutine: .just([])
            )
        case .all:
            let allRoutines = input.viewDidLoad
                .flatMapLatest { [weak self] _ -> Observable<[RoutineInfo]> in
                    print("flatMapLatest 진입")
                    guard let self else { print("self가 nil"); return .empty() }
                    return self.fetchAllRoutines()
                }
                .catch { error -> Observable<[RoutineInfo]> in
                    print("루틴 로드 실패: \(error)")
                    return .just([])
                }
                .share(replay: 1, scope: .whileConnected)

            return Output(
                todaysRoutine: .just([]),
                allRoutine: allRoutines
            )
        }
    }
}

private extension ManageRoutineViewModel {
    func fetchAllRoutines() -> Observable<[RoutineInfo]> {
        guard let userId else { return .empty() }
        return routineUseCase.fetchAllRoutines(uid: userId)
    }

    func fetchTodayRoutines() -> Observable<[DummyTodaysRoutine]> {
        guard let userId else { return .empty() }
        return .just(mockTodaysRoutine) // TODO: - API 호출 로직으로 수정 필요
    }
}
