//
//  AuthRepositoryProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/12/25.
//
import RxSwift

protocol AuthRepositoryProtocol {
    func deleteAccount() -> Observable<Void>
}
