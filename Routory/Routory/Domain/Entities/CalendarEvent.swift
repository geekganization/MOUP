//
//  CalendarEvent.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - CalendarEvent

/// Firestore의 calendars/{calendarId}/events/{eventId} 문서에 대응되는 일정 이벤트 모델
struct CalendarEvent: Codable {

    /// 이벤트 제목
    let title: String

    /// 날짜 전체 문자열 (예: "2025.06.09")
    let eventDate: String

    /// 시작 시간 (예: "09:00")
    let startTime: String

    /// 종료 시간 (예: "18:00")
    let endTime: String

    /// 생성자 UID
    let createdBy: String

    /// 연도 (정렬 및 필터링 용도)
    let year: Int
    /// 월 (정렬 및 필터링 용도)
    let month: Int
    /// 일 (정렬 및 필터링 용도)
    let day: Int

    /// 연결된 루틴 ID 리스트 (users/{id}/routine/{id})
    let routineIds: [String]
    
    /// 반복 요일
    let repeatDays: [String]
    
    /// 메모
    let memo: String

    init(title: String, eventDate: String, startTime: String, endTime: String, createdBy: String, year: Int, month: Int, day: Int, routineIds: [String], repeatDays: [String], memo: String) {
        self.title = title
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
        self.createdBy = createdBy
        self.year = year
        self.month = month
        self.day = day
        self.routineIds = routineIds
        self.repeatDays = repeatDays
        self.memo = memo
    }
}

struct CalendarEventInfo: Codable {
    let id: String
    let calendarEvent: CalendarEvent
}
