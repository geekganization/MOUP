//
//  HomeViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import Foundation
import RxSwift
import RxRelay

enum RefreshType {
    case normal
    case silent
}

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
    private let userTypeRelay = BehaviorRelay<UserType>(value: .owner)
    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: [])
    private let refreshTypeRelay = BehaviorRelay<RefreshType>(value: .normal)
    private let silentRefreshTrigger = PublishRelay<Void>()

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
        let deleteWorkplaceBtnTapped: Observable<String>
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
            input.viewDidLoad.map { _ in RefreshType.normal },
            input.refreshBtnTapped.map { _ in RefreshType.normal },
            silentRefreshTrigger.map { _ in RefreshType.silent }
        )

        dataLoadTrigger
            .withLatestFrom(refreshTypeRelay) { _, refreshType in refreshType }
            .flatMapLatest { [weak self] refreshType -> Observable<User> in
                print("transform - user triggered")
                switch refreshType {
                case .normal:
                    LoadingManager.start()
//                    break
                case .silent: break
                }
                guard let self else { return .empty() }
                return self.userUseCase.fetchUser(uid: userId)
            }
            .do(onNext: { user in
                print("user: \(user)")
            })
            .flatMapLatest { [weak self] user -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> in
                guard let self else { return .empty() }

                let userType = UserType(role: user.role)
                self.userTypeRelay.accept(userType)

                return self.fetchHomeData(userType: userType)
            }
            .withLatestFrom(refreshTypeRelay) { homeData, refreshType in
                return (homeData, refreshType)
            }
            .subscribe(onNext: { [weak self] result, refreshType in
                guard let self else { return }
                switch refreshType {
                case .normal:
                    LoadingManager.stop()
//                    break
                case .silent:
                    break
                }
                self.headerDataRelay.accept(result.0)
                self.firstSectionDataRelay.accept(result.1)
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

        input.deleteWorkplaceBtnTapped
            .flatMapLatest { [weak self] workplaceId -> Observable<Void> in
                guard let self else { return .empty() }
                print("deleteWorkplaceBtnTapped")
                return workplaceUseCase.deleteOrLeaveWorkplace(workplaceId: workplaceId, uid: userId)
                    .catch { error in
                        print(error)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.silentRefreshTrigger.accept(())
            })
            .disposed(by: disposeBag)

        return Output(
            sectionData: firstSectionDataRelay.asObservable(),
            expandedIndexPath: expandedIndexPathRelay.asObservable(),
            headerData: headerDataRelay.asObservable(),
            userType: userTypeRelay.asObservable()
        )
    }

    // MARK: - Home에서 필요한 데이터 불러오는 메서드
    private func fetchHomeData(userType: UserType) -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> {
        let calendar = Calendar.current
        let currentDate = Date()

        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else {
            return .empty()
        }

        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let previousComponents = calendar.dateComponents([.year, .month], from: previousMonthDate)

        guard let currentYear = currentComponents.year,
              let currentMonth = currentComponents.month,
              let previousYear = previousComponents.year,
              let previousMonth = previousComponents.month else {
            return .empty()
        }
        return Observable.combineLatest(
                    // 1️⃣ 모든 근무지 정보
                    self.workplaceUseCase.fetchAllWorkplacesForUser(uid: userId)
                        .do(onNext: { workplaces in
                            print("🏢 [근무지 데이터] 성공 - 개수: \(workplaces.count)")
                            print("🏢 [근무지 데이터] 내용: \(workplaces)")
                        })
                        .do(onError: { error in
                            print("💥 [근무지 데이터] 실패: \(error)")
                        })
                        .do(onSubscribe: {
                            print("🔄 [근무지 데이터] 구독 시작")
                        }),

                    // 2️⃣ 현재 월 근무 요약
                    self.workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: currentYear, month: currentMonth)
                        .do(onNext: { summary in
                            print("📊 [현재 월 요약] 성공 - \(currentYear)년 \(currentMonth)월")
                            print("📊 [현재 월 요약] 내용: \(summary)")
                        })
                        .do(onError: { error in
                            print("💥 [현재 월 요약] 실패: \(error)")
                        })
                        .do(onSubscribe: {
                            print("🔄 [현재 월 요약] 구독 시작 - \(currentYear)년 \(currentMonth)월")
                        }),

                    // 3️⃣ 이전 월 근무 요약
                    self.workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: previousYear, month: previousMonth)
                        .do(onNext: { summary in
                            print("📈 [이전 월 요약] 성공 - \(previousYear)년 \(previousMonth)월")
                            print("📈 [이전 월 요약] 내용: \(summary)")
                        })
                        .do(onError: { error in
                            print("💥 [이전 월 요약] 실패: \(error)")
                        })
                        .do(onSubscribe: {
                            print("🔄 [이전 월 요약] 구독 시작 - \(previousYear)년 \(previousMonth)월")
                        }),

                    // 4️⃣ 오늘의 루틴 이벤트
                    routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: Date())
                        .do(onNext: { events in
                            print("⏰ [오늘 루틴] 성공 - 근무지별 이벤트 개수: \(events.count)")
                            for (workplaceName, eventList) in events {
                                print("⏰ [오늘 루틴] \(workplaceName): \(eventList.count)개 이벤트")
                                for event in eventList {
                                    print("⏰ [오늘 루틴] - 이벤트: \(event)")
                                }
                            }
                        })
                        .do(onError: { error in
                            print("💥 [오늘 루틴] 실패: \(error)")
                        })
                        .do(onSubscribe: {
                            print("🔄 [오늘 루틴] 구독 시작")
                        })
                        .catchAndReturn([:])
                        .do(onNext: { events in
                            if events.isEmpty {
                                print("⚠️ [오늘 루틴] catchAndReturn으로 빈 딕셔너리 반환됨")
                            }
                        })
                )
//        return Observable.combineLatest (
//            self.workplaceUseCase.fetchAllWorkplacesForUser(uid: userId),
//            self.workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: currentYear, month: currentMonth),
//            self.workplaceUseCase.fetchMonthlyWorkSummary(uid: userId, year: previousYear, month: previousMonth),
//            routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: userId, date: Date())
//                .catchAndReturn([:])
//        )
        .map { workplaces, currentSummaries, previousSummaries, todayRoutines in
            print("내 근무지들: \(workplaces)")
            print("내 유저타입: \(userType)")

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
                            id: workplaceId,
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
                            id: workplaceId,
                            isOfficial: workplaceInfo.workplace.isOfficial,
                            storeName: workplaceInfo.workplace.workplacesName,
                            daysUntilPayday: PaydayCalculator.calculateDaysUntilPayday(payDay: payday),
                            totalLaborCost: totalAmount,
                            inviteCode: workplaceInfo.workplace.inviteCode
                        )
                    )
                    items .append(storeItem)
                }
            }

            let todayRoutinesCount = Set(todayRoutines.values // 중복
                .flatMap { $0 } // 이벤트 단위 평면화
                .flatMap { $0.routineIds }) // 이벤트 내 routineId 평면화
                .count

            print("오늘의 루틴 개수: \(todayRoutinesCount)")

            let firstSectionData = HomeTableViewFirstSection(
                header: userType == .worker ? "나의 근무지" : "나의 매장",
                items: items
            )

            return (
                HomeHeaderInfo(
                    monthlyAmount: currentAmount,
                    amountDifference: currentAmount - previousAmount,
                    todayRoutineCount: todayRoutinesCount),
                [firstSectionData])
        }
    }
}
