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
    
    func fetchMonthlyWorkSummaryDailySeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDailySeparated]>
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
    
    func fetchMonthlyWorkSummaryDailySeparated(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDailySeparated]> {
        let workplacesRef = db.collection("users").document(uid).collection("workplaces")
        
        return Observable.create { observer in
            // 최상위 workplaces 리스너
            let workplacesListener = workplacesRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let workplaceIds = snapshot?.documents.map { $0.documentID } ?? []
                if workplaceIds.isEmpty {
                    observer.onNext([])
                    return
                }
                
                let perWorkplaceObs = workplaceIds.map { workplaceId -> Observable<WorkplaceWorkSummaryDailySeparated?> in
                    Observable<WorkplaceWorkSummaryDailySeparated?>.create { o in
                        let workplaceDocRef = self.db.collection("workplaces").document(workplaceId)
                        let workerDocRef = workplaceDocRef.collection("worker").document(uid)
                        
                        // 각각의 리스너 반환값 저장
                        var workerListener: ListenerRegistration?
                        var calendarListener: ListenerRegistration?
                        
                        // workplace 리스너
                        let workplaceListener = workplaceDocRef.addSnapshotListener { workplaceDoc, _ in
                            // worker 리스너
                            workerListener = workerDocRef.addSnapshotListener { workerDoc, _ in
                                guard let wData = workplaceDoc?.data(),
                                      let workplaceName = wData["workplacesName"] as? String,
                                      let workerData = workerDoc?.data(),
                                      let wage = workerData["wage"] as? Int,
                                      let wageCalcMethod = workerData["wageCalcMethod"] as? String,
                                      let wageType = workerData["wageType"] as? String,
                                      let breakTimeMinutes = workerData["breakTimeMinutes"] as? Int
                                else {
                                    o.onNext(nil); o.onCompleted(); return
                                }
                                // 캘린더(개인/공유) 리스너
                                calendarListener = self.db.collection("calendars")
                                    .whereField("workplaceId", isEqualTo: workplaceId)
                                    .addSnapshotListener { calSnap, _ in
                                        let personalCalIds = calSnap?.documents.filter { ($0.data()["isShared"] as? Bool) == false }.map { $0.documentID } ?? []
                                        let sharedCalIds   = calSnap?.documents.filter { ($0.data()["isShared"] as? Bool) == true  }.map { $0.documentID } ?? []
                                        
                                        func fetchEvents(calIds: [String]) -> Observable<[CalendarEventInfo]> {
                                            let eventObs = calIds.map { calId in
                                                Observable<[CalendarEventInfo]>.create { eventObserver in
                                                    // 이벤트 리스너 반환값
                                                    let eventsListener = self.db.collection("calendars").document(calId)
                                                        .collection("events")
                                                        .whereField("year", isEqualTo: year)
                                                        .whereField("month", isEqualTo: month)
                                                        .addSnapshotListener { evtSnap, _ in
                                                            let events: [CalendarEventInfo] = evtSnap?.documents.compactMap { doc in
                                                                do {
                                                                    let data = try JSONSerialization.data(withJSONObject: doc.data())
                                                                    let event = try JSONDecoder().decode(CalendarEvent.self, from: data)
                                                                    return CalendarEventInfo(id: doc.documentID, calendarEvent: event)
                                                                } catch { return nil }
                                                            } ?? []
                                                            eventObserver.onNext(events)
                                                        }
                                                    // 이벤트 리스너 해제
                                                    return Disposables.create {
                                                        eventsListener.remove()
                                                    }
                                                }
                                            }
                                            return eventObs.isEmpty ? .just([]) : Observable.zip(eventObs).map { $0.flatMap { $0 } }
                                        }
                                        
                                        let personalEventsObs = fetchEvents(calIds: personalCalIds)
                                        let sharedEventsObs   = fetchEvents(calIds: sharedCalIds)
                                        
                                        Observable.zip(personalEventsObs, sharedEventsObs)
                                            .subscribe(onNext: { personalEvents, sharedEvents in
                                                func groupSummary(_ events: [CalendarEventInfo]) -> [String: (events: [CalendarEventInfo], totalHours: Double, totalWage: Int)] {
                                                    let groupedByDay = Dictionary(grouping: events) { $0.calendarEvent.eventDate }
                                                    return groupedByDay.mapValues { events in
                                                        let totalHours = events.reduce(0.0) { $0 + EventService.calculateWorkedHours(start: $1.calendarEvent.startTime, end: $1.calendarEvent.endTime) }
                                                        let totalWage: Int
                                                        if wageCalcMethod == "monthly" {
                                                            let workDays = groupedByDay.count
                                                            totalWage = workDays > 0 ? wage / workDays : wage
                                                        } else {
                                                            totalWage = Int(Double(wage) * totalHours)
                                                        }
                                                        return (events, totalHours, totalWage)
                                                    }
                                                }
                                                o.onNext(WorkplaceWorkSummaryDailySeparated(
                                                    workplaceId: workplaceId,
                                                    workplaceName: workplaceName,
                                                    wage: wage,
                                                    wageCalcMethod: wageCalcMethod,
                                                    wageType: wageType,
                                                    breakTimeMinutes: breakTimeMinutes,
                                                    personalSummary: groupSummary(personalEvents),
                                                    sharedSummary: groupSummary(sharedEvents)
                                                ))
                                                o.onCompleted()
                                            }, onError: { error in
                                                o.onError(error)
                                            })
                                            .disposed(by: self.disposeBag)
                                    }
                            }
                        }
                        // workplace Observable의 Disposables.create에서 모두 해제
                        return Disposables.create {
                            workplaceListener.remove()
                            workerListener?.remove()
                            calendarListener?.remove()
                        }
                    }
                }
                
                Observable.zip(perWorkplaceObs)
                    .map { $0.compactMap { $0 } }
                    .subscribe(onNext: { summaries in
                        observer.onNext(summaries)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            // workplaces 리스너 해제
            return Disposables.create {
                workplacesListener.remove()
            }
        }
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
        let workplacesRef = db.collection("users").document(uid).collection("workplaces")
        
        return Observable.create { observer in
            let workplacesListener = workplacesRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let workplaceIds = snapshot?.documents.map { $0.documentID } ?? []

                let calendarQueryObservables = workplaceIds.map { workplaceId in
                    Observable<([String], [String])>.create { calendarObserver in
                        let listener = self.db.collection("calendars")
                            .whereField("workplaceId", isEqualTo: workplaceId)
                            .addSnapshotListener { snap, error in
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
                            }
                        return Disposables.create { listener.remove() }
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
                                    let eventListener = query.addSnapshotListener { snap, error in
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
                                    }
                                    return Disposables.create { eventListener.remove() }
                                }
                            }
                        }
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
                    .subscribe(onNext: { (personalEvents, sharedEvents) in
                        observer.onNext((personal: personalEvents, shared: sharedEvents))
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create { workplacesListener.remove() }
        }
    }

    
    static func calculateWorkedHours(start: String, end: String) -> Double {
        // 예: "09:00" ~ "18:00" -> Double 시간 반환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let startDate = dateFormatter.date(from: start),
              let endDate = dateFormatter.date(from: end) else { return 0 }
        let interval = endDate.timeIntervalSince(startDate)
        return max(interval / 3600, 0)
    }
}
