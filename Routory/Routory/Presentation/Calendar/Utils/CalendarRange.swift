//
//  CalendarRange.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

import Foundation

/// `JTACMonthView`의 생성 범위를 설정하는 `enum`
enum CalendarRange: Int {
    /// 캘린더 생성 시작 연도
    case startYear = 2001
    /// 캘린더 생성 끝 연도
    case endYear = 2100
    
    var referenceDate: Date {
        switch self {
        case .startYear:
            guard let date = DateFormatter.yearMonthDateFormatter.date(from: "\(self.rawValue).01.01") else {
                return Date(timeIntervalSinceReferenceDate: 0.0)
            }
            return date
        case .endYear:
            guard let date = DateFormatter.yearMonthDateFormatter.date(from: "\(self.rawValue).12.31") else {
                return .now
            }
            return date
        }
    }
}
