//
//  ShiftRegistrationViewModel.swift
//  Routory
//
//  Created by tlswo on 6/18/25.
//

import Foundation
import RxSwift
import FirebaseAuth

final class WorkplaceListViewModel {

    private let workplaceUseCase: WorkplaceUseCase
    private let disposeBag = DisposeBag()

    private(set) var workplaceInfos: [WorkplaceInfo] = []

    init(workplaceUseCase: WorkplaceUseCase) {
        self.workplaceUseCase = workplaceUseCase
    }

    func fetchWorkplaces(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자 UID가 없습니다.")
            completion()
            return
        }
        
        workplaceUseCase.fetchAllWorkplacesForUser2(uid: uid)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] workplaces in
                self?.workplaceInfos = workplaces
                completion()
            }, onError: { error in
                print("근무지 불러오기 실패: \(error)")
                completion()
            })
            .disposed(by: disposeBag)
    }
}
