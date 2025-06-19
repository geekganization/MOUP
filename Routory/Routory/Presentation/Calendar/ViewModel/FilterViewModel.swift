//
//  FilterViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

final class FilterViewModel {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let disposeBag = DisposeBag()
    
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let calendarMode: Observable<CalendarMode>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let workplaceInfoListRelay: BehaviorRelay<[WorkplaceInfo]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let workplaceInfoListRelay = BehaviorRelay<[WorkplaceInfo]>(value: [])
        
        input.calendarMode
            .subscribe(with: self) { owner, calendarMode in
                guard let uid = UserManager.shared.firebaseUid else { return }
                owner.workplaceUseCase.fetchAllWorkplacesForUser(uid: uid)
                    .subscribe(with: self) { owner, workplaceInfoList in
                        if calendarMode == .shared {
                            let filtered = workplaceInfoList.filter { $0.workplace.isOfficial }
                            workplaceInfoListRelay.accept(filtered)
                        } else {
                            workplaceInfoListRelay.accept(workplaceInfoList)
                        }
                    } onError: { owner, error in
                        owner.logger.error("\(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
                
            }.disposed(by: disposeBag)
        
        return Output(workplaceInfoListRelay: workplaceInfoListRelay)
    }
    
    // MARK: - Initializer
    
    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }
}
