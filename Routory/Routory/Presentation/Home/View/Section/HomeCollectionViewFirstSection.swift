//
//  HomeTableViewFirstSection.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import Foundation
import RxDataSources

enum HomeSectionItem {
    case workplace(String) // 후에 WorkplaceModel로
    case store(String) // 후에 StoreModel로
}

struct HomeCollectionViewFirstSection {
    var header: String
    var items: [HomeSectionItem]
}

extension HomeCollectionViewFirstSection: SectionModelType {
//    typealias Item = ~~ // 실제 타입 사용 시 적용

    init(original: HomeCollectionViewFirstSection, items: [HomeSectionItem]) {
        self = original
        self.items = items
    }
}
