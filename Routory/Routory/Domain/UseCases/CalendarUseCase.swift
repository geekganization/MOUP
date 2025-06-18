//
//  CalendarUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

final class CalendarUseCase: CalendarUseCaseProtocol {
    private let repository: CalendarRepository
    init(repository: CalendarRepository) {
        self.repository = repository
    }
    func shareCalendarWithUser(calendarId: String, uid: String) -> Observable<Void> {
        return repository.addUserToCalendarSharedWith(calendarId: calendarId, uid: uid)
    }
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?> {
        return repository.fetchCalendarIdByWorkplaceId(workplaceId: workplaceId)
    }
    func addEventToCalendar(calendarId: String, event: CalendarEvent) -> Observable<Void> {
        return repository.addEventToCalendar(calendarId: calendarId, event: event)
    }
}
