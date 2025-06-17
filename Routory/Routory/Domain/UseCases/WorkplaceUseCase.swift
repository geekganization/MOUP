//
//  WorkplaceUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

final class WorkplaceUseCase: WorkplaceUseCaseProtocol {
    private let repository: WorkplaceRepository
    init(repository: WorkplaceRepository) {
        self.repository = repository
    }
    func getWorkplaceInfoByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?> {
        repository.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
    func registerWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void> {
        repository.addWorkerToWorkplace(workplaceId: workplaceId, uid: uid, workerDetail: workerDetail)
    }
}
