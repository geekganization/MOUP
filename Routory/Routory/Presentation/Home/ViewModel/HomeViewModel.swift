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

    private lazy var firstSectionData = BehaviorRelay<[HomeTableViewFirstSection]>(value: [HomeTableViewFirstSection(header: "나의 근무지", items: [.workplace(dummyWorkplace)])])

    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: [])

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let refreshBtnTapped: PublishRelay<Void>
        let cellTapped: Observable<IndexPath>
    }

    struct Output {
        let sectionData: Observable<[HomeTableViewFirstSection]>
        let expandedIndexPath: Observable<Set<IndexPath>>
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: {
                print("viewDidLoad - 데이터 로드")
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
                    print("셀 접기: \(indexPath)")
                } else {
                    newExpanded.insert(indexPath)
                    print("셀 펼치기: \(indexPath)")
                }
                print("새로운 expanded: \(newExpanded)")
                return newExpanded
            }
            .bind(to: expandedIndexPathRelay)
            .disposed(by: disposeBag)

        return Output(
            sectionData: firstSectionData.asObservable(),
            expandedIndexPath: expandedIndexPathRelay.asObservable()
        )
    }
}
