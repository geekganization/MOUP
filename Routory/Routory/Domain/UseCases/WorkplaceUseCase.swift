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
    // 사용자 uid를 기반으로 모든 근무지를 조회해서 WorkplaceInfo 배열을 받아온다
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]> {
        return repository.fetchAllWorkplacesForUser1(uid: uid)
    }
    func fetchAllWorkplacesForUser2(uid: String) -> Observable<[WorkplaceInfo]> {
        return repository.fetchAllWorkplacesForUser2(uid: uid)
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
    // workplaceId를 이용해 [WorkerDetailInfo]를 받아온다
    func fetchWorkerListForWorkplace(workplaceId: String) -> Observable<[WorkerDetailInfo]> {
        return repository.fetchWorkerListForWorkplace(workplaceId: workplaceId)
    }
    
    func fetchMonthlyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummary]> {
        return repository.fetchMonthlyWorkSummary(uid: uid, year: year, month: month)
    }
    func fetchDailyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDaily]> {
        return repository.fetchDailyWorkSummary(uid: uid, year: year, month: month)
    }
    func deleteOrLeaveWorkplace(workplaceId: String, uid: String) -> Observable<Void> {
        return repository.deleteOrLeaveWorkplace(workplaceId: workplaceId, uid: uid)
    }
}
