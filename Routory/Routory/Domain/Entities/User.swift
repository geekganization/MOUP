//
//  User.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - User

/// Firestore의 users/{userId} 문서에 대응되는 사용자 모델
struct User: Codable {
    
    /// 사용자 닉네임 또는 이름
    let userName: String

    /// 사용자 역할 ("worker" 또는 "owner")
    let role: String

    init(userName: String, role: String, workplaceList: [String]) {
        self.userName = userName
        self.role = role
        self.workplaceList = workplaceList
    }
}
