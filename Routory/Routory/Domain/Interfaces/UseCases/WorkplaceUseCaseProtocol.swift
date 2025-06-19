//
//  Untitled.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

protocol WorkplaceUseCaseProtocol {
    func getWorkplaceInfoByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?>
    func registerWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void>
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]>
    func fetchAllWorkplacesForUser2(uid: String) -> Observable<[WorkplaceInfo]>
    func createWorkplaceWithCalendarAndMaybeWorker(
            uid: String,
            role: Role,
            workplace: Workplace,
            workerDetail: WorkerDetail?,
            color: String
        ) -> Observable<String>
    func fetchWorkerListForWorkplace(workplaceId: String) -> Observable<[WorkerDetailInfo]>
    func fetchMonthlyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummary]>
    func fetchDailyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDaily]>
    func deleteOrLeaveWorkplace(workplaceId: String, uid: String) -> Observable<Void>
}
