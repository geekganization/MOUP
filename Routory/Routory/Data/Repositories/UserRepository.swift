//
//  UserRepository.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//
import RxSwift


final class UserRepository: UserRepositoryProtocol {
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func createUser(uid: String, user: User) -> Observable<Void> {
        return userService.createUser(uid: uid, user: user)
    }
    
    func deleteUser(uid: String) -> Observable<Void> {
        return userService.deleteUser(uid: uid)
    }
    
    func fetchUser(uid: String) -> Observable<User> {
        return userService.fetchUser(uid: uid)
    }
    
    func updateUserName(uid: String, newUserName: String) -> Observable<Void> {
        return userService.updateUserName(uid: uid, newUserName: newUserName)
    }
    func createWorkplace(
            workplace: Workplace,
            role: Role,
            workerDetail: WorkerDetail?,
            uid: String
        ) -> Observable<String> {
            return userService.createWorkplace(
                workplace: workplace,
                role: role,
                workerDetail: workerDetail,
                uid: uid
            )
        }
    
    func addWorkplaceToUser(uid: String, workplaceId: String) -> Observable<Void> {
        return userService.addWorkplaceToUser(uid: uid, workplaceId: workplaceId)
    }
}
