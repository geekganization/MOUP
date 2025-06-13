//
//  WorkCalendar.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - WorkCalendar

/// Firestore의 calendars/{calendarId} 문서에 대응되는 캘린더 정보 모델
struct WorkCalendar: Codable {

    /// 캘린더 이름
    let calendarName: String

    /// 공유 여부 (true = 모든 인원 열람 가능)
    let isShared: Bool

    /// 생성자 UID
    let ownerId: String

    /// 연결된 근무지 ID
    let workplaceId: String
    
    /// 캘린더를 공유하는 사용자 ID 배열
    let sharedWith: [String]

    init(calendarName: String, isShared: Bool, ownerId: String, workplaceId: String, sharedWith: [String]) {
        self.calendarName = calendarName
        self.isShared = isShared
        self.ownerId = ownerId
        self.workplaceId = workplaceId
        self.sharedWith = sharedWith
    }
}
