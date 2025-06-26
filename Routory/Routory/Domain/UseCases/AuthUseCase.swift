//
//  AuthUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/12/25.
//
import RxSwift

final class AuthUseCase: AuthUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    func deleteAccount() -> Observable<Void> {
        authRepository.deleteAccount()
    }
}
