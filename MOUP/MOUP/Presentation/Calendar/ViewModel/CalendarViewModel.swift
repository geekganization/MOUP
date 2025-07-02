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
    private let routineUseCase: RoutineUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let loadMonthEvent: Observable<(year: Int, month: Int)>
        let calendarMode: Observable<CalendarMode>
        let filterModel: Observable<FilterModel?>
        let searchRoutineId: Observable<String>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarModelListRelay: PublishRelay<(personal: [CalendarModel], shared: [CalendarModel])>
        let searchedRoutineTitleRelay: PublishRelay<String>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarModelListRelay = PublishRelay<(personal: [CalendarModel], shared: [CalendarModel])>()
        let searchedRoutineTitleRelay = PublishRelay<String>()
        
        Observable.combineLatest(input.loadMonthEvent, input.calendarMode, input.filterModel)
            .withUnretained(self)
            .flatMap { owner, combined -> Observable<(personal: [CalendarModel], shared: [CalendarModel])> in
                let ((year, month), calendarMode, filterModel) = combined
                guard let uid = UserManager.shared.firebaseUid else { return .empty() }
                
                // TODO: 직전달, 이번달, 다음달 3개월씩 불러오기
                return owner.eventUseCase.fetchMonthlyWorkSummaryDailySeparated(uid: uid, year: year, month: month)
                    .flatMap { workplaceWorkSummaryDailyList -> Observable<(personal: [CalendarModel], shared: [CalendarModel])> in
                        
                        var personalModelObservables: [Observable<CalendarModel>] = []
                        var sharedModelObservables: [Observable<CalendarModel>] = []
                        let sortedWorkplaceWorkSummaryList = workplaceWorkSummaryDailyList.sorted(by: { $0.workplaceName < $1.workplaceName })
                        var filterFlag = false
                        
                        for workplaceSummary in sortedWorkplaceWorkSummaryList {
                            if calendarMode == .personal {
                                if filterModel != nil && filterModel?.workplaceId != workplaceSummary.workplaceId { continue }
                            } else {
                                if filterModel == nil {
                                    // 공유 캘린더 모드 최초 진입 시 근무지 목록(가나다순) 중 제일 처음 근무지로 필터 걸림
                                    if workplaceSummary.isOfficial && !filterFlag {
                                        filterFlag = true
                                    } else {
                                        continue
                                    }
                                    
                                } else if filterModel?.workplaceId != workplaceSummary.workplaceId {
                                    continue
                                }
                            }
                            
                            // Personal Events 처리
                            for personalEventList in workplaceSummary.personalSummary.values {
                                for event in personalEventList.events {
                                    let modelObservable = owner.createCalendarModelObservable(for: event, with: workplaceSummary)
                                    personalModelObservables.append(modelObservable)
                                }
                            }
                            
                            // Shared Events 처리
                            for sharedEventList in workplaceSummary.sharedSummary.values {
                                for event in sharedEventList.events {
                                    let modelObservable = owner.createCalendarModelObservable(for: event, with: workplaceSummary)
                                    
                                    // 생성자가 '나'인 경우, 개인 캘린더에도 추가
                                    if event.calendarEvent.createdBy == uid {
                                        personalModelObservables.append(modelObservable)
                                    }
                                    sharedModelObservables.append(modelObservable)
                                }
                            }
                        }
                        
                        // 만약 생성된 Observable이 없다면 즉시 빈 배열을 방출하도록 처리
                        let personalEvents = Observable.zip(personalModelObservables).ifEmpty(default: [])
                        let sharedEvents = Observable.zip(sharedModelObservables).ifEmpty(default: [])
                        
                        // 두 스트림(personal, shared)이 모두 완료되면 최종 결과를 튜플로 조합
                        return Observable.zip(personalEvents, sharedEvents) { personal, shared in
                            return (personal: personal, shared: shared)
                        }
                    }
                    .catch { [weak self] error in
                        self?.logger.error("\(error.localizedDescription)")
                        return .empty() // 에러 발생 시 빈 결과 방출
                    }
            }
            .subscribe(with: self) { owner, calendarModelList in
                // 모든 fetchUser 작업이 완료된 후에 이 코드가 실행됩니다.
                var mutableList = calendarModelList
                mutableList.personal.sort(by: owner.calendarModelSort)
                mutableList.shared.sort(by: owner.calendarModelSort)
                calendarModelListRelay.accept(mutableList)
            }.disposed(by: disposeBag)
        
        input.searchRoutineId
            .withUnretained(self)
            .flatMap({ owner, searchId -> Observable<(searchId: String, routineInfoList: [RoutineInfo])> in
                guard let uid = UserManager.shared.firebaseUid else { return .empty() }
                return owner.routineUseCase.fetchAllRoutines(uid: uid)
                    .map { return (searchId: searchId, routineInfoList: $0) }
            })
            .subscribe(with: self) { owner, routineTuple in
                let (searchRoutineId, routineInfoList) = routineTuple
                
                guard let searchedRoutineInfo = routineInfoList.first(where: { $0.id == searchRoutineId }) else { return }
                searchedRoutineTitleRelay.accept(searchedRoutineInfo.routine.routineName)
            }.disposed(by: disposeBag)
        
        return Output(calendarModelListRelay: calendarModelListRelay,
                      searchedRoutineTitleRelay: searchedRoutineTitleRelay)
    }
    
    // MARK: - Initializer
    
    init(eventUseCase: EventUseCaseProtocol, routineUseCase: RoutineUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.eventUseCase = eventUseCase
        self.routineUseCase = routineUseCase
        self.userUseCase = userUseCase
    }
}

// MARK: - Private Methods

private extension CalendarViewModel {
    /// 중복 코드를 줄이기 위한 Helper 메서드
    func createCalendarModelObservable(for event: CalendarEventInfo, with workplaceSummary: WorkplaceWorkSummaryDailySeparated) -> Observable<CalendarModel> {
        return self.userUseCase.fetchUser(uid: event.calendarEvent.createdBy)
            .map { user in
                return CalendarModel(
                    workplaceId: workplaceSummary.workplaceId,
                    workplaceName: workplaceSummary.workplaceName,
                    isOfficial: workplaceSummary.isOfficial,
                    workerName: user.userName,
                    color: LabelColorString(rawValue: workplaceSummary.color) ?? ._default,
                    wage: workplaceSummary.wage,
                    wageCalcMethod: workplaceSummary.wageCalcMethod,
                    wageType: workplaceSummary.wageType,
                    breakTimeMinutes: BreakTimeMinutesDecimal(rawValue: workplaceSummary.breakTimeMinutes ?? 0) ?? ._none,
                    eventInfo: event
                )
            }
        // fetchUser에서 에러가 발생하더라도 전체 스트림이 죽지 않도록 처리
            .catch { [weak self] error in
                self?.logger.error("Failed to fetch user for event: \(error.localizedDescription)")
                return .empty()
            }
    }
    
    /// `CalendarModel` 정렬 메서드
    func calendarModelSort(_ lhs: CalendarModel, _ rhs: CalendarModel ) -> Bool {
        let lhsEvent = lhs.eventInfo.calendarEvent
        let rhsEvent = rhs.eventInfo.calendarEvent
        return lhsEvent.startTime < rhsEvent.startTime || lhsEvent.endTime < rhsEvent.endTime
    }
}
