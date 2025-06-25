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
        let filterModel: Observable<FilterModel?>
        let eventCreatedBy: Observable<[String]>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarModelListRelay: PublishRelay<(personal: [CalendarModel], shared: [CalendarModel])>
        let workerNameRelay: PublishRelay<String>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarModelListRelay = PublishRelay<(personal: [CalendarModel], shared: [CalendarModel])>()
        let workerNameRelay = PublishRelay<String>()
        
        Observable.combineLatest(input.loadMonthEvent, input.filterModel)
            .subscribe(with: self, onNext: { owner, combined in
                let ((year, month), filterModel) = combined
                
                // TODO: 직전달, 이번달, 다음달 3개월씩 불러오기
                // TODO: 요일반복 로직 생각해야 함
                guard let uid = UserManager.shared.firebaseUid else { return }
                
                owner.eventUseCase.fetchMonthlyWorkSummaryDailySeparated(uid: uid, year: year, month: month)
                    .subscribe(with: self) { owner, workplaceWorkSummaryDailyList in
                        var calendarModelList: (personal: [CalendarModel], shared: [CalendarModel]) = ([], [])
                        
                        for workplaceSummary in workplaceWorkSummaryDailyList {
                            if filterModel != nil && filterModel?.workplaceId != workplaceSummary.workplaceId { continue }
                            
                            for personalEventList in workplaceSummary.personalSummary.values {
                                for event in personalEventList.events {
                                    calendarModelList.personal.append(CalendarModel(workplaceId: workplaceSummary.workplaceId,
                                                                                    workplaceName: workplaceSummary.workplaceName,
                                                                                    isOfficial: workplaceSummary.isOfficial,
                                                                                    workerName: workplaceSummary.workerName,
                                                                                    wage: workplaceSummary.wage,
                                                                                    wageCalcMethod: workplaceSummary.wageCalcMethod,
                                                                                    wageType: workplaceSummary.wageType,
                                                                                    breakTimeMinutes: BreakTimeMinutesDecimal(rawValue: workplaceSummary.breakTimeMinutes) ?? ._none,
                                                                                    eventInfo: event))
                                }
                            }
                            for sharedEventList in workplaceSummary.sharedSummary.values {
                                for event in sharedEventList.events  {
                                    calendarModelList.shared.append(CalendarModel(workplaceId: workplaceSummary.workplaceId,
                                                                                  workplaceName: workplaceSummary.workplaceName,
                                                                                  isOfficial: workplaceSummary.isOfficial,
                                                                                  workerName: workplaceSummary.workerName,
                                                                                  wage: workplaceSummary.wage,
                                                                                  wageCalcMethod: workplaceSummary.wageCalcMethod,
                                                                                  wageType: workplaceSummary.wageType,
                                                                                  breakTimeMinutes: BreakTimeMinutesDecimal(rawValue: workplaceSummary.breakTimeMinutes) ?? ._none,
                                                                                  eventInfo: event))
                                }
                            }
                        }
                        calendarModelListRelay.accept(calendarModelList)
                    }.disposed(by: owner.disposeBag)
                
            }).disposed(by: disposeBag)
        
        return Output(calendarModelListRelay: calendarModelListRelay,
                      workerNameRelay: workerNameRelay)
    }
    
    // MARK: - Initializer
    
    init(eventUseCase: EventUseCaseProtocol) {
        self.eventUseCase = eventUseCase
    }
}

// MARK: - Private Methods

private extension CalendarViewModel {
    func calendarEventInfoSort(_ lhs: CalendarEventInfo, _ rhs: CalendarEventInfo ) -> Bool {
        return lhs.calendarEvent.eventDate < rhs.calendarEvent.eventDate
        || lhs.calendarEvent.startTime < rhs.calendarEvent.startTime
        || lhs.calendarEvent.endTime < rhs.calendarEvent.endTime
    }
}
