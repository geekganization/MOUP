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
        let filterWorkplace: Observable<String>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarEventListRelay: PublishRelay<(personal: [CalendarEvent], shared: [CalendarEvent])>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarEventListRelay = PublishRelay<(personal: [CalendarEvent], shared: [CalendarEvent])>()
        
        Observable.combineLatest(input.loadMonthEvent, input.filterWorkplace)
            .subscribe(with: self, onNext: { owner, combined in
                let ((year, month), workplace) = combined
                
                // TODO: 직전달, 이번달, 다음달 3개월씩 불러오기
                guard let uid = UserManager.shared.firebaseUid else { return }
                
                owner.eventUseCase.fetchAllEventsForUserInMonthSeparated(uid: uid, year: year, month: month)
                    .subscribe(with: self) { owner, calendarEventList in
                        if workplace == "전체 보기" {
                            calendarEventListRelay.accept(calendarEventList)
                        } else {
                            let filteredPersonal = calendarEventList.personal.filter { $0.title == workplace }
                            let filteredShared = calendarEventList.shared.filter { $0.title == workplace }
                            let filteredEventList = (personal: filteredPersonal, shared: filteredShared)
                            calendarEventListRelay.accept(filteredEventList)
                        }
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
