//
//  CreateWorkerWorkplaceUseCaseProtocol.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import RxSwift

protocol CreateWorkerWorkplaceUseCaseProtocol {
    func execute(
        workplace: Workplace,
        workerDetail: WorkerDetail,
        uid: String
    ) -> Observable<String>
}
