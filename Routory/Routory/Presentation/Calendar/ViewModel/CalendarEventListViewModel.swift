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
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let eventListRelay: BehaviorRelay<[CalendarEvent]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let eventListRelay = BehaviorRelay<[CalendarEvent]>(value: [])
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                eventListRelay.accept(owner.eventList)
            }.disposed(by: disposeBag)
        
        return Output(eventListRelay: eventListRelay)
    }
    
    // MARK: - Initializer
    
    init(eventList: [CalendarEvent]) {
        self.eventList = eventList
    }
}
