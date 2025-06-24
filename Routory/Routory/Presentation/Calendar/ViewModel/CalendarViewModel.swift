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
        /// 직전달, 이번달, 다음달 3개월치 불러옴
        let loadMonthEvent: Observable<(year: Int, month: Int)>
        let filterModel: Observable<FilterModel>
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
                guard let uid = UserManager.shared.firebaseUid else { return }
                
                owner.eventUseCase.fetchMonthlyWorkSummaryDailySeparated(uid: uid, year: year, month: month)
                    .subscribe(with: self) { owner, workplaceWorkSummaryDailyList in
                        var calendarModelList: (personal: [CalendarModel], shared: [CalendarModel]) = ([], [])
                        
                        for workplaceSummary in workplaceWorkSummaryDailyList {
                            if filterModel.workplaceId == workplaceSummary.workplaceId { continue }
                            
                            for personalEventList in workplaceSummary.personalSummary.values {
                                for event in personalEventList.events {
                                    calendarModelList.personal.append(CalendarModel(workplaceId: workplaceSummary.workplaceId,
                                                                                    workplaceName: workplaceSummary.workplaceName,
                                                                                    isOfficial: workplaceSummary.isOfficial,
                                                                                    wage: workplaceSummary.wage,
                                                                                    wageCalcMethod: workplaceSummary.wageCalcMethod,
                                                                                    wageType: workplaceSummary.wageType,
                                                                                    breakTimeMinutes: workplaceSummary.breakTimeMinutes,
                                                                                    eventInfo: event))
                                }
                            }
                            for sharedEventList in workplaceSummary.sharedSummary.values {
                                for event in sharedEventList.events {
                                    calendarModelList.shared.append(CalendarModel(workplaceId: workplaceSummary.workplaceId,
                                                                                  workplaceName: workplaceSummary.workplaceName,
                                                                                  isOfficial: workplaceSummary.isOfficial,
                                                                                  wage: workplaceSummary.wage,
                                                                                  wageCalcMethod: workplaceSummary.wageCalcMethod,
                                                                                  wageType: workplaceSummary.wageType,
                                                                                  breakTimeMinutes: workplaceSummary.breakTimeMinutes,
                                                                                  eventInfo: event))
                                }
                            }
                        }
                        calendarModelListRelay.accept(calendarModelList)
                    }.disposed(by: owner.disposeBag)
                
            }).disposed(by: disposeBag)
//        
//        input.eventCreatedBy
//            .subscribe(with: self) { owner, uid in
//                owner.userUseCase.fetchUser(uid: uid)
//                    .subscribe(with: self) { owner, user in
//                        workerNameRelay.accept(user.userName)
//                    }.disposed(by: owner.disposeBag)
//                
//            }.disposed(by: disposeBag)
        
        return Output(calendarModelListRelay: calendarModelListRelay,
                      workerNameRelay: workerNameRelay)
    }
    
    // MARK: - Initializer
    
    init(eventUseCase: EventUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.eventUseCase = eventUseCase
        self.userUseCase = userUseCase
    }
}

// MARK: - Private Methods

private extension CalendarViewModel {
    func eventSort(_ lhs: CalendarEvent, _ rhs: CalendarEvent ) -> Bool {
        return lhs.eventDate < rhs.eventDate || lhs.startTime < rhs.startTime || lhs.endTime < rhs.endTime
    }
}
