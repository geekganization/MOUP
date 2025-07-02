//
//  EventUsecaseProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

protocol EventUseCaseProtocol {
    func fetchAllEventsForUserInMonthSeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])>
    
    func fetchEventsForUserOnDateSeparated(
        uid: String,
        year: Int,
        month: Int,
        day: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])>
    
    func fetchMonthlyWorkSummaryDailySeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDailySeparated]>
}
