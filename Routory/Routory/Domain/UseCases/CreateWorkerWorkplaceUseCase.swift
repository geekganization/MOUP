//
//  CreateWorkerWorkplaceUseCase.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import RxSwift

final class CreateWorkerWorkplaceUseCase: CreateWorkerWorkplaceUseCaseProtocol {
    private let repository: WorkerWorkplaceRepositoryProtocol

    init(repository: WorkerWorkplaceRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        workplace: Workplace,
        workerDetail: WorkerDetail,
        uid: String
    ) -> Observable<String> {
        return repository.createWorkplace(
            workplace: workplace,
            role: .worker,
            workerDetail: workerDetail,
            uid: uid
        )
    }
}
