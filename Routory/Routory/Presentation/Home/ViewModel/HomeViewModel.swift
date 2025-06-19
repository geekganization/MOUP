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
    private let disposeBag = DisposeBag()
    private let userUseCase: UserUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let routineUseCase: RoutineUseCaseProtocol
    private var userId: String {
        guard let userId = UserManager.shared.firebaseUid else { return "" }
        return userId
    }

    // MARK: - Mock Data

    private let dummyStore = DummyStoreInfo(isOfficial: true, storeName: "롯데리아 강북 수유점", daysUntilPayday: 13, totalLaborCost: 255300)
    private let dummyStore1 = DummyStoreInfo(isOfficial: false, storeName: "롯데리아 강북 문익점", daysUntilPayday: 11, totalLaborCost: 490000)

//    private lazy var firstSectionData = BehaviorRelay<[HomeTableViewFirstSection]>(value: [HomeTableViewFirstSection(header: "나의 근무지", items: [.workplace(dummyWorkplace), .workplace(dummyWorkplace2)])])
    private lazy var firstSectionData = BehaviorRelay<[HomeTableViewFirstSection]>(value: [HomeTableViewFirstSection(header: "나의 근무지", items: [.store(dummyStore), .store(dummyStore1)])])
    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: [])

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
            input.refreshBtnTapped.do(onNext: { LoadingManager.start() })
        )

        let user = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<User> in
                print("transform - user triggered")
                guard let self else { return .empty() }
                return self.userUseCase.fetchUser(uid: userId)
            }.share(replay: 1)

        let userType = user.map {
            UserType(role: $0.role)
        }.distinctUntilChanged()

        // 내 근무지
        let workplaceData = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[WorkplaceInfo]> in
                guard let self else { return .empty() }
                return self.workplaceUseCase.fetchAllWorkplacesForUser(uid: userId)
            }
            .share(replay: 1)

        /// 이번 달 기준 근무 요약 데이터를 다룹니다. 해당 데이터들 기반해 totalWage를 합산해 총액을 계산합니다.
        // 이번 달 근무 요약
        let currentMonthSummary = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[WorkplaceWorkSummary]> in
                let components = Calendar.current.dateComponents([.year, .month], from: Date())
                guard let self,
                      let year = components.year,
                      let month = components.month else { return .empty() }

                return workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: year, month: month)
            }

        /// 지난 달의 근무 요약 데이터를 다룹니다.\n지난 달 대비 얼마를 더 벌었는지 계산 가능합니다.
        // 지난 달 근무 요약
        let previousMonthSummary = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[WorkplaceWorkSummary]> in
                let components = Calendar.current.dateComponents([.year, .month], from: Date())
                guard let self,
                      let year = components.year,
                      let month = components.month else { return .empty() }

                return workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: year, month: month - 1)
            }

        // 오늘의 루틴
        let todaysRoutine = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[String: [CalendarEvent]]> in
                guard let self else { return .empty() }
                return routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: Date())
            }

        let homeHeaderData = Observable.combineLatest(
            workplaceData,
            currentMonthSummary,
            previousMonthSummary,
            todaysRoutine
        ) { workplace, currentSummaries, previousSummaries, todaysRoutine in
            print("homeHeaderData 합침")
            let monthlyAmount = {
                var amount = 0
                currentSummaries.forEach {
                    amount += $0.totalWage
                }
                return amount
            }()

            let previousMonthlyAmount = {
                var amount = 0
                previousSummaries.forEach {
                    amount += $0.totalWage
                }
                return amount
            }()

            let todayRoutineCount = todaysRoutine.count

            let homeHeaderData = HomeHeaderInfo(
                monthlyAmount: monthlyAmount,
                amountDifference: monthlyAmount - previousMonthlyAmount,
                todayRoutineCount: todayRoutineCount
            )
            print("homeHeaderData - \(homeHeaderData)")
            return homeHeaderData
        }
            .share(replay: 1)

        print("홈 헤더 데이터 : \(homeHeaderData)")

        input.refreshBtnTapped
            .subscribe(onNext: { [weak self] in
                print("refreshBtnTapped - 데이터 새로고침")
                LoadingManager.stop()
                // 새로고침 시 확장 상태 초기화
                self?.expandedIndexPathRelay.accept([])
            }).disposed(by: disposeBag)

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

        workplaceUseCase.fetchAllWorkplacesForUser(uid: userId)
            .subscribe(
                onNext: { [weak self] workplaces in
                    guard let self else { return }
                    let workplacesArray = workplaces.map { // TODO: - role에 따라 다른 enum type의 데이터 생성
                        let workplace = HomeSectionItem.store(
//                                                    DummyWorkplaceInfo(
//                                                        isOfficial: $0.workplace.isOfficial, 
//                                                        storeName: $0.workplace.workplacesName,
//                                                        daysUntilPayday: 18,
//                                                        totalEarned: 252000,
//                                                    )
                            DummyStoreInfo(
                                isOfficial: $0.workplace.isOfficial,
                                storeName: $0.workplace.workplacesName,
                                daysUntilPayday: 18,
                                totalLaborCost: 252000
                            )
                    )
                    return workplace
                }
                let homeFirstSectionItem = HomeTableViewFirstSection(header: "나의 근무지", items: workplacesArray)
                firstSectionData.accept([homeFirstSectionItem])
            })
            .disposed(by: disposeBag)

        routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: .now)
            .subscribe(onNext: { calendarEvents in
                print("오늘 루틴들: \(calendarEvents)")
            })
            .disposed(by: disposeBag)

        return Output(
            sectionData: firstSectionData.asObservable(),
            expandedIndexPath: expandedIndexPathRelay.asObservable(),
            headerData: homeHeaderData,
            userType: userType
        )
    }
}

// MARK: - fetch Logic
private extension HomeViewModel {

}
