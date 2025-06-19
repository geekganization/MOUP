//
//  RoutineUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/13/25.
//
import RxSwift
import Foundation

final class RoutineUseCase: RoutineUseCaseProtocol {
    private let repository: RoutineRepositoryProtocol
    
    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]> {
        return repository.fetchAllRoutines(uid: uid)
    }
    
    func createRoutine(uid: String, routine: Routine) -> Observable<Void> {
        return repository.createRoutine(uid: uid, routine: routine)
    }
    
    func updateRoutine(uid: String, routineId: String, routine: Routine) -> Observable<Void> {
        return repository.updateRoutine(uid: uid, routineId: routineId, routine: routine)
    }
    
    
    func deleteRoutine(uid: String, routineId: String) -> Observable<Void> {
        return repository.deleteRoutine(uid: uid, routineId: routineId)
    }
    
    func fetchTodayRoutineEventsGroupedByWorkplace(uid: String, date: Date) -> Observable<[String: [CalendarEvent]]> {
        return repository.fetchTodayRoutineEventsGroupedByWorkplace(uid: uid, date: date)
    }
    
}
