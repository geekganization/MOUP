//
//  DateFormatter+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

extension DateFormatter {
    /// 근무 시간 계산용 `DateFormatter`
    static let workHourDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return dateFormatter
    }()
    
    static func hourDiffDecimal(from start: String, to end: String) -> (hours: Int, minutes: Int, decimal: Double)? {
        guard let startDate = workHourDateFormatter.date(from: start),
              let endDate = workHourDateFormatter.date(from: end) else { return nil }
        
        let todayOverEnd = endDate < startDate ? Calendar.current.date(byAdding: .day, value: 1, to: endDate) ?? endDate : endDate
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: todayOverEnd)
        
        let h = components.hour ?? 0
        let m = components.minute ?? 0
        let decimalHours = Double(h) + Double(m) / 60.0
        
        return (h, m, decimalHours)
    }
}
