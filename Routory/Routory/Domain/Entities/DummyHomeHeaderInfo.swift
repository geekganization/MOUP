//
//  DummyHomeHeaderInfo.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import Foundation

struct DummyHomeHeaderInfo {
    let currentMonth: Int
    let monthlyAmount: Int          // 공통 금액 필드
    let amountDifference: Int
    let todayRoutineCount: Int

    // 역할별 computed properties
    var monthlyTitle: String {
        return "\(currentMonth)월 총 급여"
    }

    var monthlyPayrollTitle: String {
        return "\(currentMonth) 총 인건비"
    }
}
