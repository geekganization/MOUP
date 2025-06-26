//
//  DummyWorkPlaceInfo.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import Foundation

// 셀에 들어갈 데이터 + 셀 관련 로직(수정)에 필요한 데이터
struct WorkplaceCellInfo {
    let id: String
    let isOfficial: Bool

    // 근무지 수정에 필요한 데이터
    let category: String
    let workerDetail: WorkerDetail?
    let labelTitle: String
    let showDot: Bool
    let dotColor: String // 데이터 주입 시 String값을 UIColor로 바꾸는 작업 필요

    // 상단 고정 요소
    let storeName: String
    let daysUntilPayday: Int
    let totalEarned: Int

    // 총 근무
    let totalWorkTime: String

    /// 4대 보험 - 고용보험 0.9%
    let employmentInsurance: Int
    /// 4대 보험 - 건강보험 3.545%
    let healthInsurance: Int
    /// 4대 보험 - 산재보험은 근무자 입장에서 미납
    let industrialAccident: Int
    /// 4대 보험 - 국민연금 4.5%
    let nationalPension: Int

    /// 소득세 3.3%
    let incomeTax: Int
}
