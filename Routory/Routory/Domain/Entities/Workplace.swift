//
//  Workplace.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

import RxSwift
import Foundation

// MARK: - Workplace

/// Firestore의 workplaces/{workplaceId} 문서에 대응되는 근무지 정보 모델
struct Workplace: Codable {

    /// 근무지 이름
    let workplacesName: String

    /// 업종/카테고리 (예: 카페, 편의점)
    let category: String

    /// 근무지 생성자 Firebase UID
    let ownerId: String

    /// 초대 코드 (알바 연결용)
    let inviteCode: String

    /// 공식 여부 (true = 본사 지정 등)
    let isOfficial: Bool

    init(workplacesName: String, category: String, ownerId: String, inviteCode: String, isOfficial: Bool) {
        self.workplacesName = workplacesName
        self.category = category
        self.ownerId = ownerId
        self.inviteCode = inviteCode
        self.isOfficial = isOfficial
    }
}

struct WorkplaceInfo: Codable {
    
    let id: String
    let workplace: Workplace
    
}

struct WorkplaceWorkSummary {
    let workplaceId: String
    let workplaceName: String
    let wage: Int
    let wageCalcMethod: String
    let payDay: Int?
    let payWeekday: String?
    let events: [CalendarEvent]
    let totalWage: Int
}

struct WorkplaceWorkSummaryDaily {
    let workplaceId: String
    let workplaceName: String
    let wage: Int
    let dailySummary: [String: (events: [CalendarEvent], totalHours: Double, totalWage: Int)] // "2025-06-20": (이벤트리스트, 총 근무시간, 일급)
}

struct WorkplaceWorkSummaryDailySeparated {
    let workplaceId: String
    let workplaceName: String
    let wage: Int
    let wageCalcMethod: String
    let personalSummary: [String: (events: [CalendarEvent], totalHours: Double, totalWage: Int)]
    let sharedSummary: [String: (events: [CalendarEvent], totalHours: Double, totalWage: Int)]
}
