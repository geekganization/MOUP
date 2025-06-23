//
//  PaydayCalculator.swift
//  Routory
//
//  Created by 송규섭 on 6/19/25.
//

import Foundation

struct PaydayCalculator {

    /// 급여일까지 남은 일수 계산
    static func calculateDaysUntilPayday(payDay: Int?) -> Int {
        guard let payDay = payDay else {
            return 1 // 기본값
        }

        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)

        // 이번 달 급여일이 아직 안 지났으면
        if currentDay <= payDay {
            return payDay - currentDay
        }

        // 이번 달 급여일이 지났으면 다음 달 급여일까지
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: today)!
        let daysInCurrentMonth = calendar.range(of: .day, in: .month, for: today)!.count

        return (daysInCurrentMonth - currentDay) + payDay
    }
}
