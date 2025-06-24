//
//  BreakTimeMinutesString.swift
//  Routory
//
//  Created by 서동환 on 6/25/25.
//

import Foundation

enum BreakTimeMinutesString: String {
    case none = "없음"
    case aHalf = "30분"
    case anHour = "1시간"
    case anHourAndHalf = "1시간 30분"
    case twoHour = "2시간"
    case twoHourAndHalf = "2시간 30분"
    case threeHour = "3시간"
    
    var decimal: Int {
        switch self {
        case .none:
            return 0
        case .aHalf:
            return 30
        case .anHour:
            return 60
        case .anHourAndHalf:
            return 90
        case .twoHour:
            return 120
        case .twoHourAndHalf:
            return 150
        case .threeHour:
            return 180
        }
    }
}
