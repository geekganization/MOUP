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

    private let firstSectionData = BehaviorRelay<[HomeCollectionViewFirstSection]>(value: [HomeCollectionViewFirstSection(header: "나의 근무지", items: [HomeSectionItem.workplace("올리브영")])])

    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let refreshBtnTapped: PublishRelay<Void>
    }

    struct Output {
        let sectionData: Observable<[HomeCollectionViewFirstSection]>
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: {
                print("viewDidLoad - 데이터 로드")
            }).disposed(by: disposeBag)

        input.refreshBtnTapped
            .subscribe(onNext: {
                print("refreshBtnTapped - 데이터 새로고침")
            }).disposed(by: disposeBag)

        return Output(sectionData: firstSectionData.asObservable())
    }

}
