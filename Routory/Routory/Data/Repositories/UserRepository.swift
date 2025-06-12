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
    
    func createUser(user: User) -> Observable<Void> {
        return userService.createUser(user: user)
    }
    
    func deleteUser(uid: String) -> Observable<Void> {
        return userService.deleteUser(uid: uid)
    }
    func fetchUser(uid: String) -> Observable<User> {
        return userService.fetchUser(uid: uid)
    }
}
