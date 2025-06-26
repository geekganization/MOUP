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
    private let userUseCase: UserUseCaseProtocol
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let loadMonthEvent: Observable<(year: Int, month: Int)>
        let filterModel: Observable<FilterModel?>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarModelListRelay: PublishRelay<(personal: [CalendarModel], shared: [CalendarModel])>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarModelListRelay = PublishRelay<(personal: [CalendarModel], shared: [CalendarModel])>()
        
        Observable.combineLatest(input.loadMonthEvent, input.filterModel)
            .subscribe(with: self, onNext: { owner, combined in
                let ((year, month), filterModel) = combined
                
                // TODO: 직전달, 이번달, 다음달 3개월씩 불러오기
                guard let uid = UserManager.shared.firebaseUid else { return }
                
                owner.eventUseCase.fetchMonthlyWorkSummaryDailySeparated(uid: uid, year: year, month: month)
                    .subscribe(with: self) { owner, workplaceWorkSummaryDailyList in
                        
                        var calendarModelList: (personal: [CalendarModel], shared: [CalendarModel]) = ([], [])
                        let dispatchGroup = DispatchGroup()
                        
                        for workplaceSummary in workplaceWorkSummaryDailyList {
                            if filterModel != nil && filterModel?.workplaceId != workplaceSummary.workplaceId { continue }
                            
                            for personalEventList in workplaceSummary.personalSummary.values {
                                for event in personalEventList.events {
                                    dispatchGroup.enter()
                                    owner.userUseCase.fetchUser(uid: event.calendarEvent.createdBy)
                                        .subscribe(onNext: { user in
                                            let model = CalendarModel(workplaceId: workplaceSummary.workplaceId,
                                                                      workplaceName: workplaceSummary.workplaceName,
                                                                      isOfficial: workplaceSummary.isOfficial,
                                                                      workerName: user.userName,
                                                                      color: LabelColorString(rawValue: workplaceSummary.color) ?? ._default,
                                                                      wage: workplaceSummary.wage,
                                                                      wageCalcMethod: workplaceSummary.wageCalcMethod,
                                                                      wageType: workplaceSummary.wageType,
                                                                      breakTimeMinutes: BreakTimeMinutesDecimal(rawValue: workplaceSummary.breakTimeMinutes ?? 0) ?? ._none,
                                                                      eventInfo: event)
                                            calendarModelList.personal.append(model)
                                            dispatchGroup.leave()
                                        }, onError: { error in
                                            dispatchGroup.leave()
                                        }).disposed(by: owner.disposeBag)
                                    
                                }
                            }
                            for sharedEventList in workplaceSummary.sharedSummary.values {
                                for event in sharedEventList.events  {
                                    dispatchGroup.enter()
                                    owner.userUseCase.fetchUser(uid: event.calendarEvent.createdBy)
                                        .subscribe(onNext: { user in
                                            let model = CalendarModel(workplaceId: workplaceSummary.workplaceId,
                                                                      workplaceName: workplaceSummary.workplaceName,
                                                                      isOfficial: workplaceSummary.isOfficial,
                                                                      workerName: user.userName,
                                                                      color: LabelColorString(rawValue: workplaceSummary.color) ?? ._default,
                                                                      wage: workplaceSummary.wage,
                                                                      wageCalcMethod: workplaceSummary.wageCalcMethod,
                                                                      wageType: workplaceSummary.wageType,
                                                                      breakTimeMinutes: BreakTimeMinutesDecimal(rawValue: workplaceSummary.breakTimeMinutes ?? 0) ?? ._none,
                                                                      eventInfo: event)
                                            if event.calendarEvent.createdBy == uid {
                                                calendarModelList.personal.append(model)
                                            }
                                            calendarModelList.shared.append(model)
                                            dispatchGroup.leave()
                                        }, onError: { error in
                                            dispatchGroup.leave()
                                        }).disposed(by: owner.disposeBag)
                                }
                            }
                        }
                        dispatchGroup.notify(queue: .main) {
                            calendarModelList.personal.sort(by: owner.calendarModelSort)
                            calendarModelList.shared.sort(by: owner.calendarModelSort)
                            calendarModelListRelay.accept(calendarModelList)
                        }
                    } onError: { owner, error in
                        owner.logger.error("\(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
                
            }).disposed(by: disposeBag)
        
        return Output(calendarModelListRelay: calendarModelListRelay)
    }
    
    // MARK: - Initializer
    
    init(eventUseCase: EventUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.eventUseCase = eventUseCase
        self.userUseCase = userUseCase
    }
}

private extension CalendarViewModel {
    func calendarModelSort(_ lhs: CalendarModel, _ rhs: CalendarModel ) -> Bool {
        let lhsEvent = lhs.eventInfo.calendarEvent
        let rhsEvent = rhs.eventInfo.calendarEvent
        return lhsEvent.startTime < rhsEvent.startTime || lhsEvent.endTime < rhsEvent.endTime
    }
}
