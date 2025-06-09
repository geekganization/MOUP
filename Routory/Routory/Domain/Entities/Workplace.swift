//
//  Workplace.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - Workplace

/// Firestore의 workplaces/{workplaceId} 문서에 대응되는 근무지 정보 모델
struct Workplace: Codable {
    /// Firestore 문서 ID
    let id: String

    /// 근무지 이름
    let workplacesName: String

    /// 업종/카테고리 (예: 카페, 편의점)
    let category: String

    /// 근무지 생성자 Firebase UID
    let ownerId: String

    /// 초대 코드 (알바 연결용)
    let inviteCode: String

    /// 초대 코드 만료 일시 (문자열 또는 Timestamp)
    let inviteCodeExpiresAt: String

    /// 공식 여부 (true = 본사 지정 등)
    let isOfficial: Bool

    init(id: String, workplacesName: String, category: String, ownerId: String, inviteCode: String, inviteCodeExpiresAt: String, isOfficial: Bool) {
        self.id = id
        self.workplacesName = workplacesName
        self.category = category
        self.ownerId = ownerId
        self.inviteCode = inviteCode
        self.inviteCodeExpiresAt = inviteCodeExpiresAt
        self.isOfficial = isOfficial
    }
}
