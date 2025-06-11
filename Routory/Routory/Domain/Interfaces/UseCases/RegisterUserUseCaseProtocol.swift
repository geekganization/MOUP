//
//  RegisterUserUseCaseProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import RxSwift

protocol RegisterUserUseCaseProtocol {
    func execute(user: User) -> Observable<Void>
}
