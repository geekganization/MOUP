//
//  HomeTableViewFirstSection.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import Foundation
import RxDataSources

enum HomeSectionItem {
    case workplace(DummyWorkplaceInfo) // 후에 WorkplaceModel로
    case store(DummyStoreInfo) // 후에 StoreModel로
}

struct HomeTableViewFirstSection {
    var header: String
    var items: [HomeSectionItem]
}

extension HomeTableViewFirstSection: SectionModelType {
//    typealias Item = ~~ // 실제 타입 사용 시 적용

    init(original: HomeTableViewFirstSection, items: [HomeSectionItem]) {
        self = original
        self.items = items
    }
}
