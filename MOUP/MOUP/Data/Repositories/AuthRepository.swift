//
//  AuthRepository.swift
//  Routory
//
//  Created by 양원식 on 6/12/25.
//
import RxSwift

final class AuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func deleteAccount() -> Observable<Void> {
        authService.deleteAccount()
    }
}
