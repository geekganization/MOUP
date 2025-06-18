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
}
