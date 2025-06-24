//
//  NotificationViewModel.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import Foundation
import RxSwift
import RxRelay

final class NotificationViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let notificationService: DummyNotificationService
    private let notificationsRelay = BehaviorRelay<[DummyNotification]>(value: [])
    
    private let uid: String

    // MARK: - Init
    init(uid: String, notificationService: DummyNotificationService = DummyNotificationService()) {
        self.uid = uid
        self.notificationService = notificationService
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: PublishRelay<Void>
    }

    struct Output {
        let notifications: Observable<[DummyNotification]>
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[DummyNotification]> in
                guard let self = self else { return .just([]) }
                return self.notificationService.fetchUserNotifications(uid: self.uid)
                    .catchAndReturn([])
            }
            .bind(to: notificationsRelay)
            .disposed(by: disposeBag)

        return Output(notifications: notificationsRelay.asObservable())
    }
}
