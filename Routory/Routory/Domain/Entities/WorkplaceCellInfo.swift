//
//  DummyWorkPlaceInfo.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import Foundation

struct WorkplaceCellInfo {
    let id: String

    // 공유 여부
    let isOfficial: Bool

    // 상단 고정 요소
    let storeName: String
    let daysUntilPayday: Int
    let totalEarned: Int

//    // 총 근무
//    let totalWorkTime: String
//    let totalWorkPay: Int
//
//    // 주간
//    let normalWorkTime: String
//    let normalWorkPay: Int
//
//    // 야간
//    let nightWorkTime: String
//    let nightWorkPay: Int
//
//    // 대타 근무
//    let substituteWorkTime: String
//    let substituteWorkPay: Int
//
//    // 대타 근무 - 주간
//    let substituteNormalWorkTime: String
//    let substituteNormalWorkPay: Int
//
//    // 대타 근무 - 야간
//    let substituteNightWorkTime: String
//    let substituteNightWorkPay: Int
//
//    // 주휴 수당
//    let weeklyAllowancePay: Int
//
//    // 4대 보험, 소득세
//    let insuranceDeduction: Int
//    let taxDeduction: Int
}
