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
        return service.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]> {
        return service.fetchAllWorkplacesForUser2(uid: uid)
    }
    func createWorkplaceWithCalendarAndMaybeWorker(
        uid: String,
        role: Role,
        workplace: Workplace,
        workerDetail: WorkerDetail?,
        color: String
    ) -> Observable<String> {
        return service.createWorkplaceWithCalendarAndMaybeWorker(
            uid: uid,
            role: role,
            workplace: workplace,
            workerDetail: workerDetail,
            color: color
        )
    }
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void> {
        return service.addWorkerToWorkplace(workplaceId: workplaceId, uid: uid, workerDetail: workerDetail)
    }

}
