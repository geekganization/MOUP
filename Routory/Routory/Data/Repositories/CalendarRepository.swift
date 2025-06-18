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
        return calendarService.addUserToCalendarSharedWith(calendarId: calendarId, uid: uid)
    }
    
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?> {
        return calendarService.fetchCalendarIdByWorkplaceId(workplaceId: workplaceId)
    }
    
    func addEventToCalendar(calendarId: String, event: CalendarEvent) -> Observable<Void> {
        return calendarService.addEventToCalendar(calendarId: calendarId, event: event)
    }
}
