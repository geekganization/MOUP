//
//  CalendarRepository.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

final class CalendarRepository: CalendarRepositoryProtocol {
    private let calendarService: CalendarServiceProtocol
    init(calendarService: CalendarServiceProtocol) {
        self.calendarService = calendarService
    }
    func addUserToCalendarSharedWith(calendarId: String, uid: String) -> Observable<Void> {
        calendarService.addUserToCalendarSharedWith(calendarId: calendarId, uid: uid)
    }
}
