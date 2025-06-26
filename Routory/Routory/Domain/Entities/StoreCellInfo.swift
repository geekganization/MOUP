//
//  DummyStoreInfo.swift
//  Routory
//
//  Created by 송규섭 on 6/19/25.
//

import Foundation

struct StoreCellInfo {
    // 공유 여부
    let id: String
    let isOfficial: Bool

    // 근무지 수정에 필요한 데이터
    let category: String
    let labelTitle: String
    let showDot: Bool
    let dotColor: String // 데이터 주입 시 String값을 UIColor로 바꾸는 작업 필요

    // 상단 고정 요소
    let storeName: String
    let daysUntilPayday: Int
    let totalLaborCost: Int
    
    let inviteCode: String
}
