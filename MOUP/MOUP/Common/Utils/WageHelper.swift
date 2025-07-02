//
//  WageHelper.swift
//  Routory
//
//  Created by 양원식 on 6/25/25.
//
import Foundation

struct WageHelper {
    /// 두 시간 문자열(예: "09:00", "18:00")을 받아 소수점 단위의 근무시간을 반환
    static func calculateWorkedHours(start: String, end: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard
            let startDate = dateFormatter.date(from: start),
            let endDate = dateFormatter.date(from: end)
        else { return 0.0 }
        
        let interval = endDate.timeIntervalSince(startDate)
        // 음수면(야간근무 등) 24시간 보정
        let hours = interval > 0 ? interval / 3600.0 : (interval + 24 * 3600) / 3600.0
        return hours
    }
}
