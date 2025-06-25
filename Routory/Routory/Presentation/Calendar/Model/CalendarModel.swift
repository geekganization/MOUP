//
//  CalendarModel.swift
//  Routory
//
//  Created by 서동환 on 6/24/25.
//

import Foundation

struct CalendarModel {
    let workplaceId: String
    let workplaceName: String
    let isOfficial: Bool
    let userName: String
    let wage: Int?
    let wageCalcMethod: String?
    let wageType: String?
    let breakTimeMinutes: BreakTimeMinutesDecimal
    let eventInfo: CalendarEventInfo
}
