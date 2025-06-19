//
//  EventService.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//

import Foundation
import RxSwift
import FirebaseFirestore

/// 캘린더 이벤트(개인/공유) Firestore 통합 조회 서비스 프로토콜
protocol EventServiceProtocol {
    /**
     사용자가 소속된 모든 근무지의 '월' 단위 이벤트를 개인/공유로 분리해서 조회합니다.
     
     - Parameters:
     - uid: 조회할 사용자 UID (users/{uid})
     - year: 연도 (예: 2025)
     - month: 월 (예: 6)
     - Returns: (personal: [CalendarEvent], shared: [CalendarEvent]) - 각 배열은 조건에 맞는 이벤트 리스트
     
     Firestore Path 참고:
     - users/{uid}/workplaces/{workplaceId}
     - calendars (where workplaceId == ... , isShared)
     - calendars/{calendarId}/events (where year == ..., month == ...)
     */
    func fetchAllEventsForUserInMonthSeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])>
    
    /**
     사용자가 소속된 모든 근무지의 '특정 일자' 이벤트를 개인/공유로 분리해서 조회합니다.
     
     - Parameters:
     - uid: 조회할 사용자 UID (users/{uid})
     - year: 연도
     - month: 월
     - day: 일(1~31)
     - Returns: (personal: [CalendarEvent], shared: [CalendarEvent]) - 각 배열은 조건에 맞는 이벤트 리스트
     
     Firestore Path 참고:
     - users/{uid}/workplaces/{workplaceId}
     - calendars (where workplaceId == ... , isShared)
     - calendars/{calendarId}/events (where year == ..., month == ..., day == ...)
     */
    func fetchEventsForUserOnDateSeparated(
        uid: String,
        year: Int,
        month: Int,
        day: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])>
}

/// Firestore에서 근무지-캘린더-이벤트 트리를 타고 올라가서,
/// 월/일 단위로 이벤트를 통합적으로 조회해주는 RxSwift 기반 서비스
final class EventService: EventServiceProtocol {
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()
    
    /// [내부] 월 단위: fetchAllEventsForUserInMonthSeparated()의 실제 구현
    func fetchAllEventsForUserInMonthSeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])> {
        return fetchEvents(uid: uid, year: year, month: month, day: nil)
    }
    
    /// [내부] 일 단위: fetchEventsForUserOnDateSeparated()의 실제 구현
    func fetchEventsForUserOnDateSeparated(
        uid: String,
        year: Int,
        month: Int,
        day: Int
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])> {
        return fetchEvents(uid: uid, year: year, month: month, day: day)
    }
    
    /**
     내부 공통 함수 (월/일 단위 모두 여기서 분기 처리)
     - uid: 사용자 UID
     - year, month, day: 검색 조건 (day == nil이면 월 단위, 아니면 일 단위)
     */
    private func fetchEvents(
        uid: String,
        year: Int,
        month: Int,
        day: Int?
    ) -> Observable<(personal: [CalendarEvent], shared: [CalendarEvent])> {
        // 1. 내 근무지 id 조회(users/{uid}/workplaces)
        let workplacesRef = db.collection("users").document(uid).collection("workplaces")
        
        return Observable.create { observer in
            workplacesRef.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let workplaceIds = snapshot?.documents.map { $0.documentID } ?? []
                
                // 2. 근무지별로 캘린더 ID 추출 (isShared 플래그로 분류)
                let calendarQueryObservables = workplaceIds.map { workplaceId in
                    Observable<([String], [String])>.create { calendarObserver in
                        self.db.collection("calendars")
                            .whereField("workplaceId", isEqualTo: workplaceId)
                            .getDocuments { snap, error in
                                if let error = error {
                                    calendarObserver.onError(error)
                                    return
                                }
                                var personalCalendarIds: [String] = []
                                var sharedCalendarIds: [String] = []
                                for doc in snap?.documents ?? [] {
                                    if let isShared = doc.data()["isShared"] as? Bool {
                                        if isShared {
                                            sharedCalendarIds.append(doc.documentID)
                                        } else {
                                            personalCalendarIds.append(doc.documentID)
                                        }
                                    }
                                }
                                calendarObserver.onNext((personalCalendarIds, sharedCalendarIds))
                                calendarObserver.onCompleted()
                            }
                        return Disposables.create()
                    }
                }
                
                // 3. 모든 캘린더 id를 평탄화
                Observable.zip(calendarQueryObservables)
                    .flatMap { calendarIdTuples -> Observable<([String], [String])> in
                        let personalIds = calendarIdTuples.flatMap { $0.0 }
                        let sharedIds = calendarIdTuples.flatMap { $0.1 }
                        return .just((personalIds, sharedIds))
                    }
                // 4. 각 캘린더별로 이벤트 쿼리 (월 or 일 단위)
                    .flatMap { (personalIds, sharedIds) -> Observable<([CalendarEvent], [CalendarEvent])> in
                        let fetchEvents: ([String]) -> [Observable<[CalendarEvent]>] = { ids in
                            ids.map { calendarId in
                                Observable<[CalendarEvent]>.create { eventObserver in
                                    var query: Query = self.db.collection("calendars").document(calendarId)
                                        .collection("events")
                                        .whereField("year", isEqualTo: year)
                                        .whereField("month", isEqualTo: month)
                                    // day가 nil이 아니면 일 단위로 추가 필터
                                    if let day = day {
                                        query = query.whereField("day", isEqualTo: day)
                                    }
                                    query.getDocuments { snap, error in
                                        if let error = error {
                                            eventObserver.onError(error)
                                            return
                                        }
                                        let events = snap?.documents.compactMap { doc -> CalendarEvent? in
                                            do {
                                                let data = try JSONSerialization.data(withJSONObject: doc.data())
                                                return try JSONDecoder().decode(CalendarEvent.self, from: data)
                                            } catch {
                                                print("이벤트 디코딩 실패: \(error)")
                                                return nil
                                            }
                                        } ?? []
                                        eventObserver.onNext(events)
                                        eventObserver.onCompleted()
                                    }
                                    return Disposables.create()
                                }
                            }
                        }
                        // 5. 쿼리 결과 zip & flatMap
                        // 보완된 분기 처리
                        let personalEventsObs: Observable<[CalendarEvent]> =
                            personalIds.isEmpty
                            ? .just([])
                            : Observable.zip(fetchEvents(personalIds)).map { $0.flatMap { $0 } }
                        let sharedEventsObs: Observable<[CalendarEvent]> =
                            sharedIds.isEmpty
                            ? .just([])
                            : Observable.zip(fetchEvents(sharedIds)).map { $0.flatMap { $0 } }
                        return Observable.zip(personalEventsObs, sharedEventsObs)
                    }
                // 6. Rx 최종 반환
                    .subscribe(onNext: { (personalEvents, sharedEvents) in
                        observer.onNext((personal: personalEvents, shared: sharedEvents))
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
}
