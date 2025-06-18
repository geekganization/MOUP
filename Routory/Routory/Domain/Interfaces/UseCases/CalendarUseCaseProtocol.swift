//
//  CalendarUseCaseProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

protocol CalendarUseCaseProtocol {
    func shareCalendarWithUser(calendarId: String, uid: String) -> Observable<Void>
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?>
    func addEventToCalendar(calendarId: String, event: CalendarEvent) -> Observable<Void>
}
