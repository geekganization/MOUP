//
//  Untitled.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import RxSwift

protocol UserRepositoryProtocol {
    func createUser(uid: String, user: User) -> Observable<Void>
    func deleteUser(uid: String) -> Observable<Void>
    func fetchUser(uid: String) -> Observable<User>
    func updateUserName(uid: String, newUserName: String) -> Observable<Void>
    func createWorkplace(
            workplace: Workplace,
            role: Role,
            workerDetail: WorkerDetail?,
            uid: String
        ) -> Observable<String>
    func addWorkplaceToUser(uid: String, workplaceId: String) -> Observable<Void>
    func fetchUserNotRx(uid: String, completion: @escaping (Result<User, Error>) -> Void)
    func fetchUserWorkplaceColor(uid: String, workplaceId: String) -> Observable<UserWorkplace?>
}
