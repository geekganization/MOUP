//
//  WorkerWorkplaceRepositoryProtocol.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import RxSwift

protocol WorkerWorkplaceRepositoryProtocol {
    func createWorkplace(
        workplace: Workplace,
        role: Role,
        workerDetail: WorkerDetail?,
        uid: String
    ) -> Observable<String>
}
