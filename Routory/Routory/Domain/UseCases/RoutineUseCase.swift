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
    
    /// 근무지별로 오늘 날짜의 '루틴이 연결된' 이벤트들을 실시간으로 조회합니다.
    /// - Parameters:
    ///   - uid: 사용자 UID (users/{uid})
    ///   - date: 조회할 날짜 (Date)
    /// - Returns: [근무지이름: [CalendarEvent]] 형태의 딕셔너리 Observable
    ///
    /// - Note:
    ///   이 메서드는 Firestore의 실시간 리스너(addSnapshotListener)를 활용하여,
    ///   각 근무지별 오늘의 루틴 이벤트에 변동(추가/수정/삭제)이 생길 때마다 자동으로 최신 값을 전달합니다.
    ///   즉, 구독 중에는 데이터가 변경될 때마다 최신 딕셔너리가 연속적으로 방출됩니다.
    ///   구독을 해제하면 Firestore 리스너도 자동으로 해제되어 리소스 누수 없이 안전하게 동작합니다.
    ///
    /// - 사용 예시:
    ///   useCase.fetchTodayRoutineEventsGroupedByWorkplace(uid: uid, date: date)
    ///       .subscribe(onNext: { groupedEvents in
    ///           // groupedEvents: [근무지이름: [오늘의 루틴이벤트]]
    ///           // → 데이터 변경 시마다 실시간 반영
    ///       })
    ///       .disposed(by: disposeBag)
    func fetchTodayRoutineEventsGroupedByWorkplace(uid: String, date: Date) -> Observable<[String: [CalendarEvent]]> {
        return repository.fetchTodayRoutineEventsGroupedByWorkplace(uid: uid, date: date)
    }
    
}
