//
//  UserManager.swift
//  Routory
//
//  Created by 송규섭 on 6/18/25.
//

import Foundation
import FirebaseAuth

final class UserManager {
    static let shared = UserManager()

    private init() {}

    var firebaseUid: String? {
        return Auth.auth().currentUser?.uid
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
