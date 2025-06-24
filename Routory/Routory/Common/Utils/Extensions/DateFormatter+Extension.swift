//
//  DateFormatter+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

import Then

extension DateFormatter {
    /// `calendarView`에서 `dataSource` 관련 데이터의 연/월 형식을 만들기 위한 `DateFormatter`
    static let dataSourceDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// 근무 시간 계산용 `DateFormatter`
    static let workHourDateFormatter = DateFormatter().then() {
        $0.dateFormat = "HH:mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
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
