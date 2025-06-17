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
        repository.addUserToCalendarSharedWith(calendarId: calendarId, uid: uid)
    }
}
