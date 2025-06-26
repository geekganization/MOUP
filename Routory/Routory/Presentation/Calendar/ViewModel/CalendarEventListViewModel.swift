//
//  CalendarEventListViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

final class CalendarEventListViewModel {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let calendarUseCase: CalendarUseCaseProtocol
    
    private let disposeBag = DisposeBag()
    
    private var calendarModelList: [CalendarModel] = []
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let loadEventList: Observable<Void>
        let deleteEventIndexPath: Observable<IndexPath>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarModelListRelay: BehaviorRelay<[CalendarModel]>
        let deleteEventResultRelay: PublishRelay<Bool>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarModelListRelay = BehaviorRelay<[CalendarModel]>(value: [])
        let deleteEventResultRelay = PublishRelay<Bool>()
        
        input.loadEventList
            .subscribe(with: self) { owner, _ in
                calendarModelListRelay.accept(owner.calendarModelList)
            }.disposed(by: disposeBag)
        
        input.deleteEventIndexPath
            .subscribe(with: self) { owner, indexPath in
                guard let uid = UserManager.shared.firebaseUid else { return }
                let workspaceId = owner.calendarModelList[indexPath.row].workplaceId
                let eventId = owner.calendarModelList[indexPath.row].eventInfo.id
                
                owner.calendarUseCase.fetchCalendarIdByWorkplaceId(workplaceId: workspaceId)
                    .subscribe(with: self) { owner, calendarId in
                        guard let calendarId else { return }
                        owner.calendarUseCase.deleteEventFromCalendarIfPermitted(calendarId: calendarId, eventId: eventId, uid: uid)
                            .subscribe(with: self) { owner, _ in
                                owner.logger.debug("이벤트 삭제 성공")
                                owner.calendarModelList.remove(at: indexPath.row)
                                calendarModelListRelay.accept(owner.calendarModelList)
                                deleteEventResultRelay.accept(true)
                            } onError: { owner, error in
                                owner.logger.error("이벤트 삭제 실패: \(error.localizedDescription)")
                                deleteEventResultRelay.accept(false)
                            }.disposed(by: owner.disposeBag)

                    }.disposed(by: owner.disposeBag)
                
            }.disposed(by: disposeBag)
        
        return Output(calendarModelListRelay: calendarModelListRelay,
                      deleteEventResultRelay: deleteEventResultRelay)
    }
    
    // MARK: - Initializer
    
    init(calendarUseCase: CalendarUseCaseProtocol, calendarModelList: [CalendarModel]) {
        self.calendarUseCase = calendarUseCase
        self.calendarModelList = calendarModelList
    }
}
