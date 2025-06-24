//
//  DummyCommonNotification.swift
//  Routory
//
//  Created by 송규섭 on 6/17/25.
//

import Foundation

struct DummyNotification {
    let isRead: Bool // 읽었는지에 대한 여부, 페이지 나갈 때 기존 isRead가 false인 값들을 true로 업데이트하는 로직이 필요할 것 같다.
    let title: String
    let content: String
    let time: String // ex. 3분 전
    let type: NotificationType
    let referenceId: String
}

enum NotificationType {
    case common // 초대 승인 요청 알림을 제외한 모든 알림
    case approval(status: ApprovalStatus) // 초대 승인 요청 알림
}

enum ApprovalStatus: String {
    case pending = "대기"
    case approved = "승인"
    case rejected = "거절"
}
