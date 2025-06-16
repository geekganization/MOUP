//
//  RoutineRepository.swift
//  Routory
//
//  Created by 양원식 on 6/13/25.
//
import RxSwift

final class RoutineRepository: RoutineRepositoryProtocol {
    private let service: RoutineServiceProtocol
    
    init(service: RoutineServiceProtocol) {
        self.service = service
    }
    
    func fetchAllRoutines(uid: String) -> Observable<[RoutineInfo]> {
        return service.fetchAllRoutines(uid: uid)
    }
    
    func createRoutine(uid: String, routine: Routine) -> Observable<Void> {
        return service.createRoutine(uid: uid, routine: routine)
    }
    
}
