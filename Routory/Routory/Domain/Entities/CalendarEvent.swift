//
//  CalendarEvent.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - CalendarEvent

/// Firestore의 calendars/{calendarId}/events/{eventId} 문서에 대응되는 일정 이벤트 모델
struct CalendarEvent: Codable {
    /// 이벤트 ID (Firestore 문서 ID)
    let id: String

    /// 이벤트 제목
    let title: String

    /// 날짜 전체 문자열 (예: "2025년 6월 9일")
    let eventDate: String

    /// 시작 시간 (예: "09:00")
    let startTime: String

    /// 종료 시간 (예: "18:00")
    let endTime: String

    /// 색상 HEX 문자열 (예: "#FF0000")
    let color: String

    /// 생성자 UID
    let createdBy: String

    /// 연도, 월, 일 (정렬 및 필터링 용)
    let year: Int
    let month: Int
    let day: Int

    /// 연결된 루틴 ID 리스트 (users/{id}/routine/{id})
    let routineIds: [String]

    init(id: String, title: String, eventDate: String, startTime: String, endTime: String, color: String, createdBy: String, year: Int, month: Int, day: Int, routineIds: [String]) {
        self.id = id
        self.title = title
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.createdBy = createdBy
        self.year = year
        self.month = month
        self.day = day
        self.routineIds = routineIds
    }
}
