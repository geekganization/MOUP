//
//  WorkerWorkplaceRepository.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import RxSwift

final class WorkerWorkplaceRepository: WorkerWorkplaceRepositoryProtocol {
    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func createWorkplace(
        workplace: Workplace,
        role: Role,
        workerDetail: WorkerDetail?,
        uid: String
    ) -> Observable<String> {
        return userService.createWorkplace(
            workplace: workplace,
            role: role,
            workerDetail: workerDetail,
            uid: uid
        )
    }
}
