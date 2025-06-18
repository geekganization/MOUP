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
    private var userId: String? {
        return UserManager.shared.firebaseUid
    }

    // MARK: - Mock Data
    let dummyWorkplace = DummyWorkplaceInfo(
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
    private lazy var dummyWorkerHeaderInfo = DummyHomeHeaderInfo(currentMonth: 6, monthlyAmount: 516000, amountDifference: 32000, todayRoutineCount: 4)

    private lazy var firstSectionData = BehaviorRelay<[HomeTableViewFirstSection]>(value: [HomeTableViewFirstSection(header: "나의 근무지", items: [.workplace(dummyWorkplace), .workplace(dummyWorkplace2)])])
    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: [])
    private lazy var workerHomeHeaderInfoRelay = BehaviorRelay<DummyHomeHeaderInfo>(value: dummyWorkerHeaderInfo)

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
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: {
                print("viewDidLoad - 데이터 로드")
                // TODO: - userId, headerInfo, cellInfo 저장
                
            }).disposed(by: disposeBag)

        input.refreshBtnTapped
            .subscribe(onNext: { [weak self] in
                print("refreshBtnTapped - 데이터 새로고침")
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

        return Output(
            sectionData: firstSectionData.asObservable(),
            expandedIndexPath: expandedIndexPathRelay.asObservable(),
            headerData: workerHomeHeaderInfoRelay.asObservable()
        )
    }
}

// MARK: - fetch Logic
private extension HomeViewModel {

}
