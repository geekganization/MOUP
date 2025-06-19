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
    // WorkplaceUseCase에서 fetchAllWorkplacesForUser에서 workplaceInfo의 id를 받아 여기에 넘겨서
    // Calendar id를 받아온다
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?> {
        return repository.fetchCalendarIdByWorkplaceId(workplaceId: workplaceId)
    }
    // Calendar id랑 근무등록 event를 addEventToCalendar에 넘겨준다 이러면 데이터 저장
    func addEventToCalendar(calendarId: String, event: CalendarEvent) -> Observable<Void> {
        return repository.addEventToCalendar(calendarId: calendarId, event: event)
    }
    
    func deleteEventFromCalendarIfPermitted(calendarId: String, eventId: String, uid: String) -> Observable<Void> {
        return repository.deleteEventFromCalendarIfPermitted(calendarId: calendarId, eventId: eventId, uid: uid)
    }
}
