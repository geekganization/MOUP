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
        return repository.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
    func registerWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void> {
        return repository.addWorkerToWorkplace(workplaceId: workplaceId, uid: uid, workerDetail: workerDetail)
    }
    // 모든 근무지를 조회해서 해당하는 uid의 WorkplaceInfo를 받아온다
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]> {
        return repository.fetchAllWorkplacesForUser(uid: uid)
    }
    func createWorkplaceWithCalendarAndMaybeWorker(
        uid: String,
        role: Role,
        workplace: Workplace,
        workerDetail: WorkerDetail?,
        color: String
    ) -> Observable<String> {
        return repository.createWorkplaceWithCalendarAndMaybeWorker(
            uid: uid,
            role: role,
            workplace: workplace,
            workerDetail: workerDetail,
            color: color
        )
    }
}
