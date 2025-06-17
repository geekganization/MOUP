//
//  CalendarRepositoryProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//

import RxSwift

protocol CalendarRepositoryProtocol {
    func addUserToCalendarSharedWith(calendarId: String, uid: String) -> Observable<Void>
    func fetchCalendarIdByWorkplaceId(workplaceId: String) -> Observable<String?>
}
