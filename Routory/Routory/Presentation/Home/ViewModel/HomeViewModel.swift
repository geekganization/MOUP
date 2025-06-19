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
    private var userId: String? {
        return UserManager.shared.firebaseUid
    }

    // MARK: - Mock Data
    let dummyWorkplace = DummyWorkplaceInfo(
        isOfficial: false,
        storeName: "맥도날드 강북 수유점",
        daysUntilPayday: 18,
        totalEarned: 252000,
        totalWorkTime: "25시간 07분",
        totalWorkPay: 252000,
        normalWorkTime: "20시간 00분",
        normalWorkPay: 200600,
        nightWorkTime: "",
        nightWorkPay: 0,
        substituteWorkTime: "05시간 07분",
        substituteWorkPay: 51344,
        substituteNormalWorkTime: "05시간 07분",
        substituteNormalWorkPay: 51344,
        substituteNightWorkTime: "",
        substituteNightWorkPay: 0,
        weeklyAllowancePay: 0,
        insuranceDeduction: 24_947,
        taxDeduction: 3_528
    )
    private lazy var dummyWorkplace2 = dummyWorkplace
    private lazy var dummyWorkplace3 = dummyWorkplace
    private lazy var dummyWorkerHeaderInfo = DummyHomeHeaderInfo(currentMonth: 6, monthlyAmount: 516000, amountDifference: 32000, todayRoutineCount: 4)

    private let dummyStore = DummyStoreInfo(isOfficial: true, storeName: "롯데리아 강북 수유점", daysUntilPayday: 13, totalLaborCost: 255300)
    private let dummyStore1 = DummyStoreInfo(isOfficial: false, storeName: "롯데리아 강북 문익점", daysUntilPayday: 11, totalLaborCost: 490000)

//    private lazy var firstSectionData = BehaviorRelay<[HomeTableViewFirstSection]>(value: [HomeTableViewFirstSection(header: "나의 근무지", items: [.workplace(dummyWorkplace), .workplace(dummyWorkplace2)])])
    private lazy var firstSectionData = BehaviorRelay<[HomeTableViewFirstSection]>(value: [HomeTableViewFirstSection(header: "나의 근무지", items: [.store(dummyStore), .store(dummyStore1)])])
    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: [])

    // MARK: - Initializer
    init(
        userUseCase: UserUseCaseProtocol,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.userUseCase = userUseCase
        self.workplaceUseCase = workplaceUseCase
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
        let headerData: Observable<DummyHomeHeaderInfo>
        let userType: Observable<UserType>
    }

    func transform(input: Input) -> Output {
        let user = input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<User> in
                print("transform - user triggered")
                guard let self, let userId = self.userId else { return .empty() }
                return self.userUseCase.fetchUser(uid: userId)
            }.share(replay: 1)

        let userType = user.map {
            UserType(role: $0.role)
        }.distinctUntilChanged()

        let headerData = input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<DummyHomeHeaderInfo> in
                print("transform - headerData triggered")
                guard let self else { return .empty() }
                return Observable.just(dummyWorkerHeaderInfo)
            }.share(replay: 1)

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

        workplaceUseCase.fetchAllWorkplacesForUser(uid: userId!)
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
//                                                        totalWorkTime: "25시간 07분",
//                                                        totalWorkPay: 252000,
//                                                        normalWorkTime: "20시간 00분",
//                                                        normalWorkPay: 200600,
//                                                        nightWorkTime: "",
//                                                        nightWorkPay: 0,
//                                                        substituteWorkTime: "05시간 07분",
//                                                        substituteWorkPay: 51344,
//                                                        substituteNormalWorkTime: "05시간 07분",
//                                                        substituteNormalWorkPay: 51344,
//                                                        substituteNightWorkTime: "",
//                                                        substituteNightWorkPay: 0,
//                                                        weeklyAllowancePay: 0,
//                                                        insuranceDeduction: 24_947,
//                                                        taxDeduction: 3_528
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

        return Output(
            sectionData: firstSectionData.asObservable(),
            expandedIndexPath: expandedIndexPathRelay.asObservable(),
            headerData: headerData,
            userType: userType
        )
    }
}

// MARK: - fetch Logic
private extension HomeViewModel {

}
