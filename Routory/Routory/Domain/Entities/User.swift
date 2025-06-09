//
//  User.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - User

/// Firestore의 users/{userId} 문서에 대응되는 사용자 모델
struct User: Codable {
    /// Firebase Auth UID (Firestore 문서 ID)
    let id: String

    /// 사용자 닉네임 또는 이름
    let userName: String

    /// 사용자 역할 ("worker" 또는 "owner")
    let role: String

    /// 사용자가 속한 workplace ID 리스트
    let workplaceList: [String]

    init(id: String, userName: String, role: String, workplaceList: [String]) {
        self.id = id
        self.userName = userName
        self.role = role
        self.workplaceList = workplaceList
    }
}
