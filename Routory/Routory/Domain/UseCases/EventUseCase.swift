//
//  EventUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

final class EventUseCase: EventUseCaseProtocol {
    private let repository: EventRepositoryProtocol

    init(repository: EventRepositoryProtocol) {
        self.repository = repository
    }
    
    /// 사용자의 소속 근무지 전체에서 해당 연/월의 이벤트를 (개인/공유)로 분리해 조회
    func fetchAllEventsForUserInMonthSeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])> {
        return repository.fetchAllEventsForUserInMonthSeparated(uid: uid, year: year, month: month)
    }
    
    /// 사용자의 소속 근무지 전체에서 특정 연/월/일의 이벤트를 (개인/공유)로 분리해 조회
    func fetchEventsForUserOnDateSeparated(
        uid: String,
        year: Int,
        month: Int,
        day: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])> {
        return repository.fetchEventsForUserOnDateSeparated(uid: uid, year: year, month: month, day: day)
    }
    
    func fetchMonthlyWorkSummaryDailySeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDailySeparated]> {
        return repository.fetchMonthlyWorkSummaryDailySeparated(uid: uid, year: year, month: month)
    }
}
