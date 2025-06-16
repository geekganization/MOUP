//
//  RoutineUseCaseProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/13/25.
//
import RxSwift

protocol RoutineUseCaseProtocol {
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]>
    func createRoutine(uid: String, routine: Routine) -> Observable<Void>
}
