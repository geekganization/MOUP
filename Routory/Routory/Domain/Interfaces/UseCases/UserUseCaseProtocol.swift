//
//  UserUseCaseProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import RxSwift

protocol UserUseCaseProtocol {
    func createUser(user: User) -> Observable<Void>
    func deleteUser(uid: String) -> Observable<Void>
}
