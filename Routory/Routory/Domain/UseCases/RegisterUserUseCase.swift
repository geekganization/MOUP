//
//  RegisterUserUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//
import RxSwift

final class RegisterUserUseCase: RegisterUserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func execute(user: User) -> Observable<Void> {
        return userRepository.createUser(user: user)
    }
}
