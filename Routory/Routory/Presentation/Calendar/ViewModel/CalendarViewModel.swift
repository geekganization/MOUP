//
//  CalendarViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import Foundation

import RxRelay
import RxSwift

final class CalendarViewModel {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    struct Input {
        let viewDidLoad: Infallible<Void>
        let calendarMode: BehaviorRelay<CalendarMode>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarEventList: PublishRelay<[CalendarEvent]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarEvent = PublishRelay<[CalendarEvent]>()
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                // TODO: 로그인된 userId의 모든 WorkCalendar, 공유 캘린더 데이터 불러오기 (직전달, 이번달, 다음달 3개월 or 모든 달?)
            }.disposed(by: disposeBag)
        
        // TODO: isShared == true인 WorkCalendar 불러오기
        
        return Output(calendarEventList: calendarEvent)
    }
    
    // MARK: - Initializer
    
    init() {
        // TODO: UseCase 주입
    }
}
