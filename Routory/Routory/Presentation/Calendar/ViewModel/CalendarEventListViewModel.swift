//
//  CalendarEventListViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

import RxRelay
import RxSwift

final class CalendarEventListViewModel {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var eventList: [CalendarEvent] = []
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let loadEventList: Observable<Void>
        let deleteEventIndexPath: Observable<IndexPath>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let eventListRelay: BehaviorRelay<[CalendarEvent]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let eventListRelay = BehaviorRelay<[CalendarEvent]>(value: [])
        
        input.loadEventList
            .subscribe(with: self) { owner, _ in
                eventListRelay.accept(owner.eventList)
            }.disposed(by: disposeBag)
        
        input.deleteEventIndexPath
            .subscribe(with: self) { owner, indexPath in
                // TODO: UseCase를 통해 삭제
            }.disposed(by: disposeBag)
        
        return Output(eventListRelay: eventListRelay)
    }
    
    // MARK: - Initializer
    
    init(eventList: [CalendarEvent]) {
        self.eventList = eventList
    }
}
