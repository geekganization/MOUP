//
//  RoutineUseCase.swift
//  Routory
//
//  Created by 양원식 on 6/13/25.
//
import RxSwift

final class RoutineUseCase: RoutineUseCaseProtocol {
    private let repository: RoutineRepositoryProtocol
    
    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchAllRoutines(uid: String) -> Observable<[Routine]> {
        return repository.fetchAllRoutines(uid: uid)
    }
}
