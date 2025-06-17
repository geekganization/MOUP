//
//  RoutineRepositoryProtocol.swift
//  Routory
//
//  Created by 양원식 on 6/13/25.
//
import RxSwift

protocol RoutineRepositoryProtocol {
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]>
    func createRoutine(uid: String, routine: Routine) -> Observable<Void>
    func deleteRoutine(uid: String, routineId: String) -> Observable<Void>
    func updateRoutine(uid: String, routineId: String, routine: Routine) -> Observable<Void> 
}
