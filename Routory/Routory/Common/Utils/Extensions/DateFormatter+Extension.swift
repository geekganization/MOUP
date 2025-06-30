//
//  DateFormatter+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

import Then

extension DateFormatter {
    /// `CalendarHeaderView`에서 `yearMonthLabel`의 연/월 형식을 만들기 위한 `DateFormatter`
    static let yearMonthDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy. MM"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// `calendarView`에서 `dataSource` 관련 데이터의 연/월 형식을 만들기 위한 `DateFormatter`
    static let dataSourceDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// 근무 시간 계산용 `DateFormatter`
    static let workHourDateFormatter = DateFormatter().then {
        $0.dateFormat = "HH:mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    static func hourDiffDecimal(from start: String, to end: String, break minus: Int = 0) -> (hours: Int, minutes: Int, decimal: Double)? {
        guard let startDate = workHourDateFormatter.date(from: start),
              let endDate = workHourDateFormatter.date(from: end) else { return nil }
        
        let subtractedEndDate = Calendar.current.date(byAdding: .minute, value: -minus, to: endDate) ?? endDate
        
        let todayOverEnd = subtractedEndDate < startDate ? Calendar.current.date(byAdding: .day, value: 1, to: subtractedEndDate) ?? subtractedEndDate : subtractedEndDate
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: todayOverEnd)
        
        let h = components.hour ?? 0
        let m = components.minute ?? 0
        let decimalHours = Double(h) + Double(m) / 60.0
        
        return (h, m, decimalHours)
    }
}
