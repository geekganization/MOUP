//
//  Untitled.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import RxSwift

protocol UserRepositoryProtocol {
    func createUser(user: User) -> Observable<Void>
}
