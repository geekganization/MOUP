//
//  WorkplaceRepositoryProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//
import RxSwift

protocol WorkplaceRepositoryProtocol {
    func fetchWorkplaceByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?>
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void>
}
