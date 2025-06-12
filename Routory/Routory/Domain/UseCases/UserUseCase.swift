//
//  RegisterUserUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//
import RxSwift

final class UserUseCase: UserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func createUser(user: User) -> Observable<Void> {
        return userRepository.createUser(user: user)
    }
    
    func deleteUser(uid: String) -> Observable<Void> {
        return userRepository.deleteUser(uid: uid)
    }
    
    func fetchUser(uid: String) -> Observable<User> {
        return userRepository.fetchUser(uid: uid)
    }
}

