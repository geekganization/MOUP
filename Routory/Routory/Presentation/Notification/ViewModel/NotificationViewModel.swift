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
    private let notificationsRelay = BehaviorRelay<[DummyNotification]>(value: [])
    private let notifications = [
        DummyNotification(isRead: false, title: "급여일 알림", content: "오늘은 김알바님 급여일이에요!\n총 예상 급여는 220,000원이에요!", time: "2분 전", type: .common),
        DummyNotification(isRead: true, title: "새 근무자 요청", content: "새 근무자 박알바님이 등록을 요청했어요!", time: "어제", type: .approval(status: .pending)),
        DummyNotification(isRead: true, title: "급여일 알림", content: "오늘은 송알바님 급여일이에요!\n총 예상 급여는 2,120,000원이에요!", time: "2분 전", type: .common),
        DummyNotification(isRead: false, title: "새 근무자 요청", content: "새 근무자 송알바님이 등록을 요청했어요!", time: "1주 전", type: .approval(status: .approved)),
        DummyNotification(isRead: true, title: "새 근무자 요청", content: "새 근무자 이알바님이 등록을 요청했어요!", time: "1주 전", type: .approval(status: .rejected))
    ]

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: PublishRelay<Void>
    }

    struct Output {
        let notifications: Observable<[DummyNotification]>
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.notificationsRelay.accept(self.notifications)
            })
            .disposed(by: disposeBag)

        return Output(notifications: notificationsRelay.asObservable())
    }
}
