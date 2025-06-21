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

    private let dummyStore = StoreCellInfo(isOfficial: true, storeName: "롯데리아 강북 수유점", daysUntilPayday: 13, totalLaborCost: 255300, inviteCode: "123456")
    private let dummyStore1 = StoreCellInfo(isOfficial: false, storeName: "롯데리아 강북 문익점", daysUntilPayday: 11, totalLaborCost: 490000, inviteCode: "123456")

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
            input.refreshBtnTapped.do(onNext: { _ in () })
        )

        let user = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<User> in
                print("transform - user triggered")
                guard let self else { return .empty() }
                return self.userUseCase.fetchUser(uid: userId)
            }
            .do(onNext: { user in
                print("user: \(user)")
            })
            .share(replay: 1)

        let userType = user.map {
            UserType(role: $0.role)
        }.distinctUntilChanged()

        // 내 근무지
        let workplaceData = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[WorkplaceInfo]> in
                guard let self else { return .empty() }
                return self.workplaceUseCase.fetchAllWorkplacesForUser(uid: userId)
            }
            .do(onNext: { workplace in
                print("workplace: \(workplace)")
            })
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
            }.do(onNext: { summaries in
                print("summaries: \(summaries)")
            })

        /// 지난 달의 근무 요약 데이터를 다룹니다.\n지난 달 대비 얼마를 더 벌었는지 계산 가능합니다.
        // 지난 달 근무 요약
        let previousMonthSummary = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[WorkplaceWorkSummary]> in
                let components = Calendar.current.dateComponents([.year, .month], from: Date())
                guard let self,
                      let year = components.year,
                      let month = components.month else { return .empty() }

                return workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: year, month: month - 1)
            }.do(onNext: { summaries in
                print("summaries: \(summaries)")
            })

        // 오늘의 루틴
        let todaysRoutine = dataLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[String: [CalendarEvent]]> in
                    guard let self else {
                        print("❌ self가 nil")
                        return .empty()
                    }
                    print("🔄 오늘 루틴 요청 시작")
                return routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: Date()).timeout(.seconds(5), scheduler: MainScheduler.instance)
                }
                .do(onNext: { routines in
                    print("✅ routines 받음: \(routines)")
                })
                .do(onError: { error in
                    print("❌ routines 에러: \(error)")
                })
                .do(onSubscribe: {
                    print("🔔 routines 구독 시작")
                })
                .catchAndReturn([:])

        let homeHeaderData = Observable.combineLatest(
            workplaceData, // 해당 데이터는 필요 없으나 헤더 로딩 시 같이 로드
            currentMonthSummary,
            previousMonthSummary,
            todaysRoutine
        ) { workplaces, currentSummaries, previousSummaries, todaysRoutine in
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

//        let homeSectionData = Observable.combineLatest(
//            workplaceData,
//            currentMonthSummary,
//            userType // TODO: - 사장님 기준 바인딩 준비
//        ) {
//            workplaces,
//            currentSummaries,
//            userType in
//            var items: [HomeSectionItem] = []
//            
//            for workplaceInfo in workplaces {
//                let workplaceId = workplaceInfo.id
//                var payday: Int? = nil
//                var totalAmount = 0 // 근무지 별 총액
//                for summary in currentSummaries {
//                    if summary.workplaceId == workplaceId {
//                        totalAmount = summary.totalWage
//                        payday = summary.payDay
//                        break
//                    }
//                }
//                
//                if userType == .worker {
//                    let workplaceItem = HomeSectionItem.workplace(
//                        WorkplaceCellInfo(
//                            isOfficial: workplaceInfo.workplace.isOfficial,
//                            storeName: workplaceInfo.workplace.workplacesName,
//                            daysUntilPayday: PaydayCalculator.calculateDaysUntilPayday(payDay: payday),
//                            totalEarned: totalAmount
//                        )
//                    )
//                    items.append(workplaceItem)
//                } else {
//                    let storeItem = HomeSectionItem.store(
//                        StoreCellInfo(
//                            isOfficial: workplaceInfo,
//                            storeName: workplaceInfo.workplace.workplacesName,
//                            daysUntilPayday: payday,
//                            totalLaborCost: totalAmount,
//                            inviteCode: workplaceInfo.workplace.inviteCode
//                        )
//                    )
//                }
//            }
//
//            let headerTitle = userType == .worker ? "나의 근무지" : "나의 매장"
//            let section = HomeTableViewFirstSection(header: headerTitle, items: items)
//        }

        input.refreshBtnTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                LoadingManager.start()
                print("refreshBtnTapped - 데이터 새로고침")
                homeHeaderData.take(1)
                    .subscribe(onNext: { _ in
                        LoadingManager.stop()
                        self.expandedIndexPathRelay.accept([])
                    })
                    .disposed(by: self.disposeBag)
                // 새로고침 시 확장 상태 초기화
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
