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
    
    private var calendarModelList: [CalendarModel] = []
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let loadEventList: Observable<Void>
        let deleteEventIndexPath: Observable<IndexPath>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let calendarModelListRelay: BehaviorRelay<[CalendarModel]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let calendarModelListRelay = BehaviorRelay<[CalendarModel]>(value: [])
        
        input.loadEventList
            .subscribe(with: self) { owner, _ in
                calendarModelListRelay.accept(owner.calendarModelList)
            }.disposed(by: disposeBag)
        
        input.deleteEventIndexPath
            .subscribe(with: self) { owner, indexPath in
                // TODO: UseCase를 통해 삭제
            }.disposed(by: disposeBag)
        
        return Output(calendarModelListRelay: calendarModelListRelay)
    }
    
    // MARK: - Initializer
    
    init(calendarModelList: [CalendarModel]) {
        self.calendarModelList = calendarModelList
    }
}
