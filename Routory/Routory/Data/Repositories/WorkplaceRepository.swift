//
//  WorkplaceRepository.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

final class WorkplaceRepository: WorkplaceRepositoryProtocol {
    private let service: WorkplaceServiceProtocol
    init(service: WorkplaceServiceProtocol) {
        self.service = service
    }
    func fetchWorkplaceByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?> {
        service.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void> {
        service.addWorkerToWorkplace(workplaceId: workplaceId, uid: uid, workerDetail: workerDetail)
    }
}
