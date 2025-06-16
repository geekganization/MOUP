//
//  UserWorkplace.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

// MARK: - Workplace

/// Firestore의 users/{userId}/workplace/{workplaceId} 문서에 대응되는 근무지 사용자 설정 모델
struct UserWorkplace: Codable {
    
    /// 사용자가 설정한 근무지/매장 색상
    let color: String
    
    /// 메모
    let memo: String
    
    init(color: String, memo: String) {
        self.color = color
        self.memo = memo
    }
}
