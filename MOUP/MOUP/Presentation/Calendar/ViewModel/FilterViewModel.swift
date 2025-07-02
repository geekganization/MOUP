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
        let filterModelListRelay: BehaviorRelay<[FilterModel]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        let filterModelListRelay = BehaviorRelay<[FilterModel]>(value: [])
        
        input.calendarMode
            .subscribe(with: self) { owner, calendarMode in
                guard let uid = UserManager.shared.firebaseUid else { return }
                owner.workplaceUseCase.fetchAllWorkplacesForUser(uid: uid)
                    .subscribe(with: self) { owner, workplaceInfoList in
                        let modelList: [FilterModel]
                        if calendarMode == .shared {
                            let filtered = workplaceInfoList.filter { $0.workplace.isOfficial }
                            modelList = filtered.map { FilterModel(workplaceId: $0.id, workplaceName: $0.workplace.workplacesName) }.sorted(by: { $0.workplaceName < $1.workplaceName })
                        } else {
                            modelList = [FilterModel(workplaceId: "", workplaceName: "전체 보기")] + workplaceInfoList.map { FilterModel(workplaceId: $0.id, workplaceName: $0.workplace.workplacesName) }.sorted(by: { $0.workplaceName < $1.workplaceName })
                        }
                        filterModelListRelay.accept(modelList)
                    } onError: { owner, error in
                        owner.logger.error("\(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
                
            }.disposed(by: disposeBag)
        
        return Output(filterModelListRelay: filterModelListRelay)
    }
    
    // MARK: - Initializer
    
    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }
}
