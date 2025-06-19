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
    private let service = UserService()

    private init() {}

    var firebaseUid: String? {
        return Auth.auth().currentUser?.uid
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

    func getUserName(completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = firebaseUid else {
            let error = NSError(domain: "UserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user"])
            completion(.failure(error))
            return
        }

        service.fetchUserNotRx(uid: uid) { result in
            switch result {
            case .success(let user):
                completion(.success(user.userName))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
