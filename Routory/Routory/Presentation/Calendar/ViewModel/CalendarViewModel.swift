//
//  CalendarViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

final class CalendarViewModel {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let disposeBag = DisposeBag()
    
    private let eventUseCase: EventUseCaseProtocol
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        /// 직전달, 이번달, 다음달 3개월치 불러옴
        let loadMonthEvent: Observable<(year: Int, month: Int)>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarEventListRelay: PublishRelay<(personal: [CalendarEvent], shared: [CalendarEvent])>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarEventListRelay = PublishRelay<(personal: [CalendarEvent], shared: [CalendarEvent])>()
        
        input.loadMonthEvent
            .subscribe(with: self, onNext: { owner, yearMonth in
                // TODO: 로그인된 userId의 모든 WorkCalendar, 공유 캘린더 데이터 불러오기 (직전달, 이번달, 다음달 3개월 or 모든 달?)
                guard let uid = UserManager.shared.firebaseUid else { return }
                dump(yearMonth)
                let (year, month) = yearMonth
                
                owner.eventUseCase.fetchAllEventsForUserInMonthSeparated(uid: uid, year: year, month: month)
                    .subscribe(with: self) { owner, calendarEventList in
                        calendarEventListRelay.accept(calendarEventList)
                    } onError: { owner, error in
                        owner.logger.error("\(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
            }).disposed(by: disposeBag)
        
        return Output(calendarEventListRelay: calendarEventListRelay)
    }
    
    // MARK: - Initializer
    
    init(eventUseCase: EventUseCaseProtocol) {
        self.eventUseCase = eventUseCase
    }
}
