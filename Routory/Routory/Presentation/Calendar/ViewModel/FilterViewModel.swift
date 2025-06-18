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
    private let calendarUseCase: CalendarUseCaseProtocol
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let workplaceInfoListRelay: BehaviorRelay<[WorkplaceInfo]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let workplaceInfoListRelay = BehaviorRelay<[WorkplaceInfo]>(value: [])
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                guard let uid = UserManager.shared.firebaseUid else { return }
                owner.workplaceUseCase.fetchAllWorkplacesForUser(uid: uid)
                    .subscribe(with: self) { owner, workplaceInfoList in
                        workplaceInfoListRelay.accept(workplaceInfoList)
                    } onError: { owner, error in
                        owner.logger.error("\(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)

            }.disposed(by: disposeBag)
        
        return Output(workplaceInfoListRelay: workplaceInfoListRelay)
    }
    
    // MARK: - Initializer
    
    init(workplaceUseCase: WorkplaceUseCaseProtocol, calendarUseCase: CalendarUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
        self.calendarUseCase = calendarUseCase
    }
}
