//
//  HomeViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import Foundation
import RxSwift
import RxRelay

final class HomeViewModel {
    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let userUseCase: UserUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let routineUseCase: RoutineUseCaseProtocol
    private var userId: String {
        guard let userId = UserManager.shared.firebaseUid else { return "" }
        return userId
    }

    private let headerDataRelay = BehaviorRelay<HomeHeaderInfo>(
        value: HomeHeaderInfo(
            monthlyAmount: 0,
            amountDifference: 0,
            todayRoutineCount: 0
        )
    )
    private let firstSectionDataRelay = BehaviorRelay<[HomeTableViewFirstSection]>(value:[ HomeTableViewFirstSection(header: "나의 근무지", items: [])])
    private let userTypeRelay = BehaviorRelay<UserType>(value: .worker)

    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: [])

    // MARK: - Mock Data

    private let dummyStore = StoreCellInfo(isOfficial: true, storeName: "롯데리아 강북 수유점", daysUntilPayday: 13, totalLaborCost: 255300, inviteCode: "123456")
    private let dummyStore1 = StoreCellInfo(isOfficial: false, storeName: "롯데리아 강북 문익점", daysUntilPayday: 11, totalLaborCost: 490000, inviteCode: "123456")

    // MARK: - Initializer
    init(
        userUseCase: UserUseCaseProtocol,
        workplaceUseCase: WorkplaceUseCaseProtocol,
        routineUseCase: RoutineUseCaseProtocol
    ) {
        self.userUseCase = userUseCase
        self.workplaceUseCase = workplaceUseCase
        self.routineUseCase = routineUseCase
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshBtnTapped: Observable<Void>
        let cellTapped: Observable<IndexPath>
    }

    struct Output {
        let sectionData: Observable<[HomeTableViewFirstSection]>
        let expandedIndexPath: Observable<Set<IndexPath>>
        let headerData: Observable<HomeHeaderInfo>
        let userType: Observable<UserType>
    }

    func transform(input: Input) -> Output {
        // 데이터 fetch 트리거
        let dataLoadTrigger = Observable.merge(
            input.viewDidLoad.map { _ in () },
            input.refreshBtnTapped.do(onNext: { _ in () })
        )

        dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<User> in
                print("transform - user triggered")
                LoadingManager.start()
                guard let self else { return .empty() }
                return self.userUseCase.fetchUser(uid: userId)
            }
            .do(onNext: { user in
                print("user: \(user)")
            })
            .subscribe(onNext: { [weak self] user in
                guard let self else { return }
                self.userTypeRelay.accept(UserType(role: user.role))
            })
            .disposed(by: disposeBag)


        // 트리거 감지 시 HomeHeaderInfo 주입
        dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> in
                guard let self else { return .empty() }
                let calendar = Calendar.current
                let currentDate = Date()

                guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else {
                    return .empty()
                }

                let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
                let previousComponents = calendar.dateComponents([.year, .month], from: previousMonthDate)

                guard let currentYear = currentComponents.year,
                      let currentMonth = currentComponents.month,
                      let previousYear = previousComponents.year,    // 🔥 previous에서 뽑아야 함
                      let previousMonth = previousComponents.month else { // 🔥 previous에서 뽑아야 함
                    return .empty()
                }

                return Observable.combineLatest (
                    self.workplaceUseCase.fetchAllWorkplacesForUser(uid: userId),
                    self.workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: currentYear, month: currentMonth),
                    self.workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: previousYear, month: previousMonth),
                    // TODO: - 루틴 조회 결과 0개에 대한 오류 해결 필요
                    routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: Date())
                        .timeout(.seconds(2), scheduler: MainScheduler.instance) // 우선 2초 타임아웃 적용 - 스플래시로 UX 최적화 필요
                        .catchAndReturn([:]),
                    userTypeRelay.asObservable()
                )
                .map { workplaces, currentSummaries, previousSummaries, todayRoutines, userType in
                    print("내 근무지들: \(workplaces)")

                    let currentAmount = currentSummaries.reduce(0) { $0 + $1.totalWage } // 이번 달 총액
                    let previousAmount = previousSummaries.reduce(0) { $0 + $1.totalWage } // 이전 달 총액

                    var items: [HomeSectionItem] = []

                    for workplaceInfo in workplaces {
                        let workplaceId = workplaceInfo.id
                        var payday: Int? = nil
                        var totalAmount = 0 // 근무지 별 총액
                        for summary in currentSummaries {
                            if summary.workplaceId == workplaceId {
                                totalAmount = summary.totalWage
                                payday = summary.payDay
                                break
                            }
                        }

                        if userType == .worker {
                            let workplaceItem = HomeSectionItem.workplace(
                                WorkplaceCellInfo(
                                    isOfficial: workplaceInfo.workplace.isOfficial,
                                    storeName: workplaceInfo.workplace.workplacesName,
                                    daysUntilPayday: PaydayCalculator.calculateDaysUntilPayday(payDay: payday),
                                    totalEarned: totalAmount
                                )
                            )
                            items.append(workplaceItem)
                        } else {
                            let storeItem = HomeSectionItem.store(
                                StoreCellInfo(
                                    isOfficial: workplaceInfo.workplace.isOfficial,
                                    storeName: workplaceInfo.workplace.workplacesName,
                                    daysUntilPayday: PaydayCalculator.calculateDaysUntilPayday(payDay: payday),
                                    totalLaborCost: totalAmount,
                                    inviteCode: workplaceInfo.workplace.inviteCode
                                )
                            )
                            items.append(storeItem)
                        }
                    }

                    let firstSectionData = HomeTableViewFirstSection(
                        header: userType == .worker ? "나의 근무지" : "나의 매장",
                        items: items
                    )

                    return (
                        HomeHeaderInfo(
                        monthlyAmount: currentAmount,
                        amountDifference: currentAmount - previousAmount,
                        todayRoutineCount: todayRoutines.count),
                        [firstSectionData])
                }
            }
            .subscribe(onNext: { [weak self] homeData in
                guard let self else { return }
                LoadingManager.stop()
                self.headerDataRelay.accept(homeData.0)
                self.firstSectionDataRelay.accept(homeData.1)
            })
            .disposed(by: disposeBag)

        // 셀 탭 이벤트 처리 - ViewModel에서 확장 상태 관리
        input.cellTapped
            .withLatestFrom(expandedIndexPathRelay) { indexPath, expanded in // TODO: - VC로 View 관련 정보를 옮기는 로직
                var newExpanded = expanded
                if newExpanded.contains(indexPath) {
                    newExpanded.remove(indexPath)
                } else {
                    newExpanded.insert(indexPath)
                }
                return newExpanded
            }
            .bind(to: expandedIndexPathRelay)
            .disposed(by: disposeBag)


        return Output(
            sectionData: firstSectionDataRelay.asObservable(),
            expandedIndexPath: expandedIndexPathRelay.asObservable(),
            headerData: headerDataRelay.asObservable(),
            userType: userTypeRelay.asObservable()
        )
    }
}

// MARK: - fetch Logic
private extension HomeViewModel {

}
