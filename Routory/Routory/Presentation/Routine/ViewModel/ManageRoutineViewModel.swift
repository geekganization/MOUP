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
    private var userId: String {
        guard let userId = UserManager.shared.firebaseUid else { return "" }
        return userId
    }
    private let routineType: RoutineType
    private let disposeBag = DisposeBag()
    private let routineUseCase: RoutineUseCaseProtocol

    // MARK: - Initializer
    init(type: RoutineType, routineUseCase: RoutineUseCaseProtocol) {
        self.routineType = type
        self.routineUseCase = routineUseCase
    }

    // MARK: - Input, Output
    struct Input {
        let refreshTriggered: Observable<Void>
    }

    struct Output {
        let todaysRoutine: Observable<[TodaysRoutine]>
        let allRoutine: Observable<[RoutineInfo]>
    }

    func transform(input: Input) -> Output {
        print("transform - ManageVC")
        print("현재 루틴 타입 - \(routineType)")
        switch routineType {
        case .today:
            print("오늘의 루틴 호출 시도")
            let todayRoutines = input.refreshTriggered
                .flatMapLatest { [weak self] _ -> Observable<[TodaysRoutine]> in
                    print("flatMapLatest 진입")
                    guard let self else { print("self가 nil"); return .empty() }

                    return Observable.combineLatest(
                        self.fetchTodayRoutines(),
                        self.fetchAllRoutines()
                    )
                    .map { [weak self] (todayEvents, allRoutines) in
                        guard let self else { return [] }
                        return todayEvents.map { (workplaceName, events) in
                            let routineIds = events.flatMap { $0.routineIds }
                            let matchedRoutines = allRoutines.filter { routineInfo in
                                routineIds.contains(routineInfo.id)
                            }

                            return TodaysRoutine(workplaceName: workplaceName, routines: matchedRoutines)
                        }
                    }
                }
                .share(replay: 1, scope: .whileConnected)
            return Output(
                todaysRoutine: todayRoutines,
                allRoutine: .just([])
            )
        case .all:
            let allRoutines = input.refreshTriggered
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
        return routineUseCase.fetchAllRoutines(uid: userId)
    }

    func fetchTodayRoutines() -> Observable<[String : [CalendarEvent]]> {
        print("fetchTodayRoutines 초기 진입(함수)")
        let result = routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: Date())
        return result

//        return .just(mockTodaysRoutine) // TODO: - API 호출 로직으로 수정 필요
    }

}
