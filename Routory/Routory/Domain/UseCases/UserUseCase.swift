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
    
    func createUser(uid: String, user: User) -> Observable<Void> {
        return userRepository.createUser(uid: uid, user: user)
    }
    
    func deleteUser(uid: String) -> Observable<Void> {
        return userRepository.deleteUser(uid: uid)
    }
    
    func fetchUser(uid: String) -> Observable<User> {
        return userRepository.fetchUser(uid: uid)
    }
    
    func updateUserName(uid: String, newUserName: String) -> Observable<Void> {
        return userRepository.updateUserName(uid: uid, newUserName: newUserName)
    }
    
    func createWorkplace(
            workplace: Workplace,
            role: Role,
            workerDetail: WorkerDetail?,
            uid: String
        ) -> Observable<String> {
            return userRepository.createWorkplace(
                workplace: workplace,
                role: role,
                workerDetail: workerDetail,
                uid: uid
            )
        }
    func addWorkplaceToUser(uid: String, workplaceId: String) -> Observable<Void> {
        return userRepository.addWorkplaceToUser(uid: uid, workplaceId: workplaceId)
    }
    func fetchUserNotRx(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        return userRepository.fetchUserNotRx(uid: uid, completion: completion)
    }
}
