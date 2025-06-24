//
//  BreakTimeMinutes.swift
//  Routory
//
//  Created by 서동환 on 6/25/25.
//

import Foundation

enum BreakTimeMinutes: Int {
    case none = 0
    case aHalf = 30
    case anHour = 60
    case anHourAndHalf = 90
    case twoHour = 120
    case twoHourAndHalf = 150
    case threeHour = 180
    
    var string: String {
        switch self {
        case .none:
            return "없음"
        case .aHalf:
            return "30분"
        case .anHour:
            return "1시간"
        case .anHourAndHalf:
            return "1시간 30분"
        case .twoHour:
            return "2시간"
        case .twoHourAndHalf:
            return "2시간 30분"
        case .threeHour:
            return "3시간"
        }
    }
}
