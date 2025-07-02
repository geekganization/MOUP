//
//  AuthUseCaseProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/12/25.
//
import RxSwift

protocol AuthUseCaseProtocol {
    func deleteAccount() -> Observable<Void>
}
