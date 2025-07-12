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

    /// 사장 입장에서 근무자들의 근무지 정보 등 요약과 함께 써야하므로 타입 정의
    typealias WorkerSummaryData = (
        workplaceId: String,
        workerId: String,
        worker: WorkerDetailInfo,
        summaries: [WorkplaceWorkSummary]
    )

    /// 급여 계산에 필요한 초깃값
    let initialPayrollResult = PayrollResult(
        employmentInsurance: 0, // 고용보험
        healthInsurance: 0,     // 건강보험
        industrialAccident: 0,  // 산재보험
        nationalPension: 0,     // 국민연금
        incomeTax: 0,          // 소득세
        netPay: 0  // 실수령액
        )

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
                case .silent: break
                }
                guard let self else { return .empty() }
                return self.userUseCase.fetchUser(uid: userId)
            }
            .do(onError: { error in
                print("HomeVM - fetchUser error: \(error)")
                LoadingManager.stop()
            })
            .do(onNext: { user in
                print("user: \(user)")
            })
            .catchAndReturn(User(userName: "", role: "worker", workplaceList: []))
            .flatMapLatest { [weak self] user -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> in
                guard let self else { return .empty() }

                let userType = UserType(role: user.role)
                self.userTypeRelay.accept(userType)

                return self.fetchHomeData(userType: userType)
                    .do(onError: { error in
                        print("fetchHomeData error: \(error)") // TODO: - 사용자에게 커스텀 alert 띄워줘야함
                        LoadingManager.stop()
                    })
                    .catchAndReturn((
                        HomeHeaderInfo(monthlyAmount: 0, amountDifference: 0, todayRoutineCount: 0),
                        [HomeTableViewFirstSection(header: "나의 근무지", items: [])]
                    ))
            }
            .withLatestFrom(refreshTypeRelay) { homeData, refreshType in
                return (homeData, refreshType)
            }
            .subscribe(onNext: { [weak self] result, refreshType in
                guard let self else { return }
                switch refreshType {
                case .normal:
                    LoadingManager.stop()
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

        return self.workplaceUseCase.fetchAllWorkplacesForUser(uid: userId)
            .flatMap { workplaces -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> in

                switch userType {
                case .worker:
                    return self.fetchWorkerHomeData(
                        workplaces: workplaces,
                        currentYear: currentYear,
                        currentMonth: currentMonth,
                        previousYear: previousYear,
                        previousMonth: previousMonth
                    )
                case .owner:
                    return self.fetchOwnerHomeData(
                        workplaces: workplaces,
                        currentYear: currentYear,
                        currentMonth: currentMonth,
                        previousYear: previousYear,
                        previousMonth: previousMonth
                    )
                }
            }
    }

    // [WorkplaceInfo] -> [WorkerDetailInfo] -> WorkerDetailInfo, [WorkplaceWorkSummary]
    private func fetchWorkerHomeData(
        workplaces: [WorkplaceInfo],
        currentYear: Int,
        currentMonth: Int,
        previousYear: Int,
        previousMonth: Int
    ) -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> {
        let workerDetailObservables = workplaces.map { workplaceInfo in
            print("workplaceInfo - \(workplaceInfo)")
            return self.workplaceUseCase.fetchWorkerListForWorkplace(workplaceId: workplaceInfo.id)
                .do(onNext: {
                    print("workerListForWorkplace - \($0)")
                })
                .map { workerDetailInfos in
                    return workerDetailInfos.first { $0.id == self.userId }?.detail
                }
                .catchAndReturn(nil)
        }

        return Observable.combineLatest(
            Observable.just(workplaces)
                .do(onNext: { print("workplaces: \($0.count)개") }),
            workerDetailObservables.isEmpty ? Observable.just([]) : Observable.zip(workerDetailObservables)
                .do(onNext: { print("workerDetails: \($0)") }),
            self.workplaceUseCase.fetchMonthlyWorkSummary(uid: self.userId, year: currentYear, month: currentMonth)
                .do(onNext: { print("currentSummary: \($0.count)개") }),
            self.workplaceUseCase.fetchMonthlyWorkSummary(uid: self.userId, year: previousYear, month: previousMonth)
                .do(onNext: { print("previousSummary: \($0.count)개") }),
            self.routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: self.userId, date: Date())
                .do(onNext: { print("todayRoutines: \($0.keys.count)개 근무지") },
                    onError: { print("todayRoutines error: \($0)") })
                .catchAndReturn([:])
        )
        .map {
            workplaces,
            workerDetails,
            currentSummaries,
            previousSummaries,
            todayRoutines in
            return self.processWorkerHomeData(
                workplaces: workplaces,
                workerDetails: workerDetails,
                currentSummaries: currentSummaries,
                previousSummaries: previousSummaries,
                todayRoutines: todayRoutines
            )
        }
    }

    private func fetchOwnerHomeData(
        workplaces: [WorkplaceInfo],
        currentYear: Int,
        currentMonth: Int,
        previousYear: Int,
        previousMonth: Int
    ) -> Observable<(HomeHeaderInfo, [HomeTableViewFirstSection])> {

        let allWorkersObservables = workplaces.map { workplaceInfo in
            return self.workplaceUseCase.fetchWorkerListForWorkplace(workplaceId: workplaceInfo.id)
                .catchAndReturn([])
        }

        let workplaceColorObservables = workplaces.map { workplaceInfo in
            return self.userUseCase.fetchUserWorkplaceColor(uid: userId, workplaceId: workplaceInfo.id)
                .map { $0?.color ?? "노란색" }
                .catchAndReturn("노란색")
        }

        return Observable.combineLatest(
            Observable.just(workplaces),
            allWorkersObservables.isEmpty ? Observable.just([]) : Observable.zip(allWorkersObservables),
            workplaceColorObservables.isEmpty ? Observable.just([]) : Observable.zip(workplaceColorObservables)
        )
        .flatMap { (workplaces: [WorkplaceInfo], allWorkers: [[WorkerDetailInfo]], workplaceColors: [String]) in

            // 🎯 핵심: 모든 근무자들의 summary 가져오기
            let allWorkerSummaryObservables: [Observable<WorkerSummaryData>] = workplaces.enumerated().flatMap { (workplaceIndex, workplace) in
                let workers = allWorkers[workplaceIndex]
                return workers.map { worker in
                    return self.workplaceUseCase.fetchMonthlyWorkSummary(
                        uid: worker.id,
                        year: currentYear,
                        month: currentMonth
                    ).map { summaries -> WorkerSummaryData in
                        return (
                            workplaceId: workplace.id,
                            workerId: worker.id,
                            worker: worker,
                            summaries: summaries
                        )
                    }.catchAndReturn((
                        workplaceId: workplace.id,
                        workerId: worker.id,
                        worker: worker,
                        summaries: []
                    ))
                }
            }

            // 이전 달 summary도 동일하게
            let allWorkerPreviousSummaryObservables: [Observable<WorkerSummaryData>] = workplaces.enumerated().flatMap { (workplaceIndex, workplace) in
                let workers = allWorkers[workplaceIndex]
                return workers.map { worker in
                    return self.workplaceUseCase.fetchMonthlyWorkSummary(
                        uid: worker.id,
                        year: previousYear,
                        month: previousMonth
                    ).map { summaries -> WorkerSummaryData in
                        return (
                            workplaceId: workplace.id,
                            workerId: worker.id,
                            worker: worker,
                            summaries: summaries
                        )
                    }.catchAndReturn((
                        workplaceId: workplace.id,
                        workerId: worker.id,
                        worker: worker,
                        summaries: []
                    ))
                }
            }

            return Observable.combineLatest(
                Observable.just(workplaces),
                Observable.just(allWorkers),
                Observable.just(workplaceColors),
                allWorkerSummaryObservables.isEmpty ? Observable.just([]) : Observable.zip(allWorkerSummaryObservables),
                allWorkerPreviousSummaryObservables.isEmpty ? Observable.just([]) : Observable.zip(allWorkerPreviousSummaryObservables),
                self.routineUseCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: self.userId, date: Date())
                    .catchAndReturn([:])
            )
        }
        .map { workplaces, allWorkers, workplaceColors, currentWorkerSummaries, previousWorkerSummaries, todayRoutines in

            return self.processOwnerHomeData(
                workplaces: workplaces,
                allWorkers: allWorkers,
                currentSummaries: currentWorkerSummaries, // 근무자별 summary
                previousSummaries: previousWorkerSummaries,
                todayRoutines: todayRoutines,
                workplaceColors: workplaceColors
            )
        }
    }

    private func processWorkerHomeData(
        workplaces: [WorkplaceInfo],
        workerDetails: [WorkerDetail?],
        currentSummaries: [WorkplaceWorkSummary],
        previousSummaries: [WorkplaceWorkSummary],
        todayRoutines: [String: [CalendarEvent]]
    ) -> (HomeHeaderInfo, [HomeTableViewFirstSection]) {
        var currentMonthlyAmount = 0
        var previousMonthlyAmount = 0
        var items: [HomeSectionItem] = []

        for (index, workplaceInfo) in workplaces.enumerated() {
            let workerDetail = workerDetails[index]
            let insuranceSettings = InsuranceSettings(
                hasEmploymentInsurance: workerDetail?.employmentInsurance ?? false,
                hasHealthInsurance: workerDetail?.healthInsurance ?? false,
                hasIndustrialAccident: workerDetail?.industrialAccident ?? false,
                hasNationalPension: workerDetail?.nationalPension ?? false
            )

            var currentTotalWorkMinutes = 0
            var currentTotalPayInfo = initialPayrollResult
            var previousTotalPayInfo = initialPayrollResult

            // 수정: 고정급이면 먼저 처리
            if workerDetail?.wageType != "시급" {
                let fixedSalary = workerDetail?.wage ?? 0
                currentMonthlyAmount += fixedSalary  // 이번 달은 무조건 포함
                
                // 이전 달은 근무기록 있을 때만 포함
                let previousSummary = previousSummaries.filter { $0.workplaceId == workplaceInfo.id }
                if let summary = previousSummary.first, !summary.events.isEmpty {
                    previousMonthlyAmount += fixedSalary
                    print("이전 달 \(fixedSalary)만큼 추가")
                }

                currentTotalPayInfo = PayrollResult(
                    employmentInsurance: -1,
                    healthInsurance: -1,
                    industrialAccident: -1,
                    nationalPension: -1,
                    incomeTax: -1,
                    netPay: fixedSalary
                )
            } else {
                // 시급인 경우에만 기존 로직 실행
                for summary in currentSummaries {
                    if summary.workplaceId == workplaceInfo.id {
                        currentTotalPayInfo = calculateWorkerPay(
                            summary: summary,
                            workerDetail: workerDetail,
                            nightAllowance: workerDetail?.nightAllowance,
                            insuranceSettings: insuranceSettings
                        )
                        currentMonthlyAmount += currentTotalPayInfo.netPay
                        currentTotalWorkMinutes = calculateTotalWorkMinutes(summary: summary)
                        break
                    }
                }

                for summary in previousSummaries {
                    if summary.workplaceId == workplaceInfo.id {
                        previousTotalPayInfo = calculateWorkerPay(
                            summary: summary,
                            workerDetail: workerDetail,
                            nightAllowance: workerDetail?.nightAllowance,
                            insuranceSettings: insuranceSettings
                        )
                        previousMonthlyAmount += previousTotalPayInfo.netPay
                        break
                    }
                }
            }

            let homeSectionItem = HomeSectionItem.workplace(
                WorkplaceCellInfo(
                    id: workplaceInfo.id,
                    isOfficial: workplaceInfo.workplace.isOfficial,
                    category: workplaceInfo.workplace.category,
                    workerDetail: workerDetail,
                    labelTitle: workerDetail?.color ?? "노란색",
                    showDot: true,
                    dotColor: workerDetail?.color ?? "노란색",
                    storeName: workplaceInfo.workplace.workplacesName,
                    daysUntilPayday: PaydayCalculator.calculateDaysUntilPayday(payDay: workerDetail?.payDay),
                    totalEarned: currentTotalPayInfo.netPay,
                    totalWorkTime: TimeParser.shared.parseToTimeString(currentTotalWorkMinutes),
                    employmentInsurance: currentTotalPayInfo.employmentInsurance,
                    healthInsurance: currentTotalPayInfo.healthInsurance,
                    industrialAccident: currentTotalPayInfo.industrialAccident,
                    nationalPension: currentTotalPayInfo.nationalPension,
                    incomeTax: currentTotalPayInfo.incomeTax
                )
            )
            items.append(homeSectionItem)
        }

        let todayRoutinesCount = Set(todayRoutines.values
            .flatMap{$0}
            .filter { event in event.createdBy == self.userId }
            .flatMap{$0.routineIds})
            .count

        let headerInfo = HomeHeaderInfo(
            monthlyAmount: currentMonthlyAmount,
            amountDifference: currentMonthlyAmount - previousMonthlyAmount,
            todayRoutineCount: todayRoutinesCount
        )

        if items.isEmpty {
            items.append(
                HomeSectionItem.workplace(
                    WorkplaceCellInfo(
                        id: "999999999",
                        isOfficial: true,
                        category: "편의점",
                        workerDetail: nil,
                        labelTitle: "",
                        showDot: true,
                        dotColor: "",
                        storeName: "MOUP 1호점",
                        daysUntilPayday: 17,
                        totalEarned: 0,
                        totalWorkTime: "",
                        employmentInsurance: 0,
                        healthInsurance: 0,
                        industrialAccident: 0,
                        nationalPension: 0,
                        incomeTax: 0
                    )
                )
            )
        }

        let sectionData = HomeTableViewFirstSection(header: "나의 근무지", items: items)

        return (headerInfo, [sectionData])
    }

    private func processOwnerHomeData(
        workplaces: [WorkplaceInfo],
        allWorkers: [[WorkerDetailInfo]],
        currentSummaries: [WorkerSummaryData],
        previousSummaries: [WorkerSummaryData],
        todayRoutines: [String: [CalendarEvent]],
        workplaceColors: [String]
    ) -> (HomeHeaderInfo, [HomeTableViewFirstSection]) {
        // 알바생 목록(workerList)에 아무도 없을 경우 0원 처리
        var currentMonthlyAmount = 0
        var previousMonthlyAmount = 0
        var items: [HomeSectionItem] = []

        for (index, workplaceInfo) in workplaces.enumerated() { // 근무지 하나씩 접근
            // 근무지 당 나온 총 인건비와 근무 시간 (한 달, 한 근무지, 근무지 내 모든 근무자 기준)
            var currentTotalLaborCost: Int = 0
            var currentTotalWorkMinutes: Int = 0

            /// 다음 버전 사장님 홈에 expand 될 때 쓰여질 알바생들의 근무 시간(분) 및 총 급여 데이터 - (workerId, value) 형태
            /// 단, 실사용 시 데이터 부정합이 이뤄질 수 있어 테스트 후 문제 생길 경우 id를 통한 일치하게 만드는 작업 필요
            var workersWorkMinutesArray: [(String, Int)] = []
            var workersPayrollData: [(String, Int)] = []

            let firstWorkerPayday = currentSummaries
                .first { $0.workplaceId == workplaceInfo.id }?
                .worker.detail.payDay ?? 1

            let currentWorkplaceSummaries = currentSummaries.filter {
                $0.workplaceId == workplaceInfo.id // 해당 id의 근무지에 속하는 근무자들 summaries
            }
            let previousWorkplaceSummaries = previousSummaries.filter {
                $0.workplaceId == workplaceInfo.id
            }

            // 🔥 현재 달 급여 계산
            for workerSummary in currentWorkplaceSummaries {
                // 🔥 고정급이면 근무기록 상관없이 먼저 처리
                if workerSummary.worker.detail.wageType != "시급" {
                    print("급여 방식이 고정입니다")
                    currentTotalLaborCost += workerSummary.worker.detail.wage
                    currentMonthlyAmount += workerSummary.worker.detail.wage
                } else {
                    // 시급인 경우만 기존 로직 실행
                    let thisWorkplaceSummaries = workerSummary.summaries.filter {
                        $0.workplaceId == workplaceInfo.id
                    }
                    guard !thisWorkplaceSummaries.isEmpty else { continue }

                    print("급여 방식이 시급입니다")
                    for summary in thisWorkplaceSummaries {
                        let payInfo = calculateWorkerPay(
                            summary: summary,
                            workerDetail: workerSummary.worker.detail,
                            nightAllowance: workerSummary.worker.detail.nightAllowance,
                            insuranceSettings: InsuranceSettings(
                                hasEmploymentInsurance: workerSummary.worker.detail.employmentInsurance,
                                hasHealthInsurance: workerSummary.worker.detail.healthInsurance,
                                hasIndustrialAccident: workerSummary.worker.detail.industrialAccident,
                                hasNationalPension: workerSummary.worker.detail.nationalPension
                            )
                        )

                        currentTotalLaborCost += payInfo.netPay
                        currentMonthlyAmount += payInfo.netPay
                    }
                }

                // 근무시간은 근무기록이 있는 경우에만 계산
                let thisWorkplaceSummaries = workerSummary.summaries.filter {
                    $0.workplaceId == workplaceInfo.id
                }
                for summary in thisWorkplaceSummaries {
                    currentTotalWorkMinutes += calculateTotalWorkMinutes(summary: summary)
                }
            }

            // 이전 달 급여 계산 - 근무기록 있는 고정급만 포함
            for workerSummary in previousWorkplaceSummaries {
                if workerSummary.worker.detail.wageType != "시급" {
                    // 이전 달은 실제 근무기록이 있을 때만 고정급 포함
                    let thisWorkplaceSummaries = workerSummary.summaries.filter {
                        $0.workplaceId == workplaceInfo.id && !$0.events.isEmpty // 근무자로 추가는 되어있지만 근무 기록은 없을 경우
                    }
                    if !thisWorkplaceSummaries.isEmpty {
                        previousMonthlyAmount += workerSummary.worker.detail.wage
                    }
                } else {
                    let thisWorkplaceSummaries = workerSummary.summaries.filter {
                        $0.workplaceId == workplaceInfo.id
                    }
                    guard !thisWorkplaceSummaries.isEmpty else { continue }

                    for summary in thisWorkplaceSummaries {
                        let payInfo = calculateWorkerPay(
                            summary: summary,
                            workerDetail: workerSummary.worker.detail,
                            nightAllowance: workerSummary.worker.detail.nightAllowance,
                            insuranceSettings: InsuranceSettings(
                                hasEmploymentInsurance: workerSummary.worker.detail.employmentInsurance,
                                hasHealthInsurance: workerSummary.worker.detail.healthInsurance,
                                hasIndustrialAccident: workerSummary.worker.detail.industrialAccident,
                                hasNationalPension: workerSummary.worker.detail.nationalPension
                            )
                        )
                        previousMonthlyAmount += payInfo.netPay
                    }
                }
            }

            let workplaceColor = index < workplaceColors.count ? workplaceColors[index] : "노란색"
            let homeSectionItem = HomeSectionItem.store(
                StoreCellInfo(
                    id: workplaceInfo.id,
                    isOfficial: workplaceInfo.workplace.isOfficial,
                    category: workplaceInfo.workplace.category,
                    labelTitle: workplaceColor,
                    showDot: true,
                    dotColor: workplaceColor,
                    storeName: workplaceInfo.workplace.workplacesName,
                    daysUntilPayday: PaydayCalculator.calculateDaysUntilPayday(payDay: firstWorkerPayday), // 근무자들 중 첫번째 근무자의 급여일을 대표로 보여줌
                    totalLaborCost: currentTotalLaborCost,
                    inviteCode: workplaceInfo.workplace.inviteCode
                )
            )
            items.append(homeSectionItem)
        }

        let todayRoutinesCount = Set(todayRoutines.values
            .flatMap{$0}
            .filter { event in event.createdBy == self.userId }
            .flatMap{$0.routineIds})
            .count

        print(" [OWNER] 루틴 계산 과정:")
        print("   - todayRoutines 키: \(Array(todayRoutines.keys))")
        print("   - todayRoutines.values: \(todayRoutines.values)")

        let headerInfo = HomeHeaderInfo(
            monthlyAmount: currentMonthlyAmount,
            amountDifference: currentMonthlyAmount - previousMonthlyAmount,
            todayRoutineCount: todayRoutinesCount
        )

        if items.isEmpty {
            items.append(
                HomeSectionItem.store(
                    StoreCellInfo(
                        id: "999999999",
                        isOfficial: true,
                        category: "편의점",
                        labelTitle: "",
                        showDot: true,
                        dotColor: "",
                        storeName: "MOUP 1호점",
                        daysUntilPayday: 17,
                        totalLaborCost: 0,
                        inviteCode: ""
                    )
                )
            )
        }

        let sectionData = HomeTableViewFirstSection(header: "나의 매장", items: items)

        return (headerInfo, [sectionData])
    }

    /// 근무지의 월 요약 정보를 통해 누적 계산된 급여(보험비 포함)를 계산하는 메서드
    private func calculateWorkerPay(
        summary: WorkplaceWorkSummary,
        workerDetail: WorkerDetail?,
        nightAllowance: Bool?,
        insuranceSettings: InsuranceSettings
    ) -> PayrollResult {
        guard let workerDetail else {
            return PayrollResult(
                employmentInsurance: 0,
                healthInsurance: 0,
                industrialAccident: 0,
                nationalPension: 0,
                incomeTax: 0,
                netPay: 0
            )
        }

        guard workerDetail.wageType == "시급" else {
            return PayrollResult(
                // TODO: - Int 타입이라 후에 -1일 경우 "-"로 표기하도록 처리 필요
                employmentInsurance: -1,
                healthInsurance: -1,
                industrialAccident: -1,
                nationalPension: -1,
                incomeTax: -1,
                netPay: workerDetail.wage // 고정일 경우 wage가 고정 급여에 대한 정보임
            )
        }
        var totalEmploymentInsurancePay: Int = 0
        var totalHealthInsurancePay: Int = 0
        var totalIndustrialAccidentPay: Int = 0
        var totalNationalPensionPay: Int = 0
        var totalIncomeTax: Int = 0
        var totalNetPay: Int = 0
        let wage: Double = Double(workerDetail.wage)
        let nightRate: Double = nightAllowance ?? false ? 1.5 : 1.0

        summary.events.forEach { event in
            let workMinutes = WorkTimeCalculator.shared.calculateWorkTime(
                start: TimeParser.shared.parseToMinutes(event.startTime),
                end: TimeParser.shared.parseToMinutes(event.endTime)
            )
            let dayWorkHour: Double = Double(workMinutes.dayMinutes) / 60.0
            let nightWorkHour: Double = Double(workMinutes.nightMinutes) / 60.0
            let beforeInsuranceAmount: Int =
            Int((dayWorkHour * wage) + (nightWorkHour * (wage * nightRate)))
            let result = PayrollCalculator.shared.calculatePay(grossPay: beforeInsuranceAmount, settings: insuranceSettings)
            totalEmploymentInsurancePay += result.employmentInsurance
            totalHealthInsurancePay += result.healthInsurance
            totalIndustrialAccidentPay += result.industrialAccident
            totalNationalPensionPay += result.nationalPension
            totalIncomeTax += result.incomeTax
            totalNetPay += result.netPay
        }

        return PayrollResult(
            employmentInsurance: totalEmploymentInsurancePay,
            healthInsurance: totalHealthInsurancePay,
            industrialAccident: totalIndustrialAccidentPay,
            nationalPension: totalNationalPensionPay,
            incomeTax: totalIncomeTax,
            netPay: totalNetPay
        )
    }

    /// 근무지의 월 요약 정보를 통해 누적 시간(분 단위)을 계산하는 메서드
    private func calculateTotalWorkMinutes(summary: WorkplaceWorkSummary) -> Int {
        var totalMinutes = 0
        summary.events.forEach {
            let workMinutes = WorkTimeCalculator.shared.calculateTotalMinutes(
                start: TimeParser.shared.parseToMinutes($0.startTime),
                end: TimeParser.shared.parseToMinutes($0.endTime)
            )
            totalMinutes += workMinutes
        }
        return totalMinutes
    }
}
