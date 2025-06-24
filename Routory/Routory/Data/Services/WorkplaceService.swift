//
//  WorkplaceService.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//

import FirebaseFirestore
import RxSwift

protocol WorkplaceServiceProtocol {
    func fetchWorkplaceByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?>
    func createWorkplaceWithCalendarAndMaybeWorker(
        uid: String,
        role: Role,
        workplace: Workplace,
        workerDetail: WorkerDetail?,
        color: String
    ) -> Observable<String>
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]>
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void>
    func fetchWorkerListForWorkplace(workplaceId: String) -> Observable<[WorkerDetailInfo]>
    func fetchMonthlyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummary]>
    func fetchDailyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDaily]>
    func deleteOrLeaveWorkplace(workplaceId: String, uid: String) -> Observable<Void>
}


final class WorkplaceService: WorkplaceServiceProtocol {
    private let db = Firestore.firestore()
    
    /// 초대코드를 통해 근무지 정보를 조회합니다.
    ///
    /// - Parameter inviteCode: 조회할 근무지의 초대코드
    /// - Returns: 조회된 WorkplaceInfo(근무지 ID + 근무지 정보)를 방출하는 Observable, 없으면 nil
    /// - Firestore 경로: workplaces (inviteCode 검색)
    func fetchWorkplaceByInviteCode(inviteCode: String) -> Observable<WorkplaceInfo?> {
        return Observable.create { observer in
            let listener = self.db.collection("workplaces")
                .whereField("inviteCode", isEqualTo: inviteCode)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    guard let document = snapshot?.documents.first else {
                        observer.onNext(nil)
                        return
                    }
                    let data = document.data()
                    if let jsonData = try? JSONSerialization.data(withJSONObject: data),
                       let workplace = try? JSONDecoder().decode(Workplace.self, from: jsonData) {
                        let id = document.documentID
                        observer.onNext(WorkplaceInfo(id: id, workplace: workplace))
                    } else {
                        observer.onNext(nil)
                    }
                }
            return Disposables.create { listener.remove() }
        }
    }

    
    /// 근무지의 worker 서브컬렉션에 알바(워커) 정보를 등록합니다.
    ///
    /// - Parameters:
    ///   - workplaceId: 근무지의 Firestore documentID
    ///   - uid: 등록할 알바(유저) UID
    ///   - workerDetail: 등록할 WorkerDetail 정보
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: workplaces/{workplaceId}/worker/{uid}
    func addWorkerToWorkplace(workplaceId: String, uid: String, workerDetail: WorkerDetail) -> Observable<Void> {
        let db = Firestore.firestore()
        return Observable.create { observer in
            do {
                let data = try Firestore.Encoder().encode(workerDetail)
                db.collection("workplaces").document(workplaceId)
                    .collection("worker").document(uid)
                    .setData(data) { error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    }
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    /// 해당 사용자가 소속된 모든 근무지 정보를 조회합니다.
    /// - Parameter uid: 유저의 UID
    /// - Returns: WorkplaceInfo 배열
    /// - Firestore 경로: users/{uid}/workplaces → workplaces/{workplaceId}
    func fetchAllWorkplacesForUser(uid: String) -> Observable<[WorkplaceInfo]> {
        let userWorkplaceRef = Firestore.firestore().collection("users").document(uid).collection("workplaces")
        return Observable<[String]>.create { observer in
            let listener = userWorkplaceRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let ids = snapshot?.documents.map { $0.documentID } ?? []
                observer.onNext(ids)
            }
            return Disposables.create {
                listener.remove()
            }
        }
        .flatMap { ids -> Observable<[WorkplaceInfo]> in
            if ids.isEmpty {
                return Observable.just([])
            }
            let db = Firestore.firestore()
            let observables: [Observable<WorkplaceInfo>] = ids.map { workplaceId in
                Observable<WorkplaceInfo>.create { detailObserver in
                    let detailListener = db.collection("workplaces").document(workplaceId).addSnapshotListener { doc, error in
                        if let doc = doc, let data = doc.data() {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: data)
                                let workplace = try JSONDecoder().decode(Workplace.self, from: jsonData)
                                detailObserver.onNext(WorkplaceInfo(id: workplaceId, workplace: workplace))
                            } catch {
                                detailObserver.onError(error)
                            }
                        }
                    }
                    return Disposables.create {
                        detailListener.remove()
                    }
                }
            }
            return Observable.zip(observables)
        }
    }
    
    
    /// 근무지, 캘린더를 동시에 생성(필요시 워커 등록)합니다.
    ///
    /// - Parameters:
    ///   - uid: 현재 유저의 UID (owner/worker)
    ///   - role: 사용자 역할(.owner 또는 .worker)
    ///   - workplace: 생성할 근무지 정보(Workplace)
    ///   - workerDetail: 알바(워커)라면 워커 정보, 아니면 nil
    ///   - color: 유저가 선택한 근무지 색상값
    /// - Returns: 생성된 workplaceId를 방출하는 Observable
    /// - Firestore 경로:
    ///     - workplaces/{workplaceId}
    ///     - calendars/{calendarId}
    ///     - users/{uid}/workplace/{workplaceId}
    ///     - workplaces/{workplaceId}/worker/{uid} (알바만)
    func createWorkplaceWithCalendarAndMaybeWorker(
        uid: String,
        role: Role,
        workplace: Workplace,
        workerDetail: WorkerDetail?,
        color: String
    ) -> Observable<String> {
        let workplaceRef = db.collection("workplaces").document()
        let workplaceId = workplaceRef.documentID
        let calendarRef = db.collection("calendars").document()
        let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces").document(workplaceId)
        
        return Observable.create { observer in
            let batch = self.db.batch()
            
            // 1. 근무지 저장
            batch.setData([
                "workplacesName": workplace.workplacesName,
                "category": workplace.category,
                "ownerId": workplace.ownerId,
                "inviteCode": workplace.inviteCode,
                "isOfficial": (role == .owner)
            ], forDocument: workplaceRef)
            
            // 2. 캘린더 저장 (조건에 맞게 필드 세팅)
            batch.setData([
                "calendarName": workplace.workplacesName,
                "isShared": (role == .owner),
                "ownerId": uid,
                "sharedWith": [],
                "workplaceId": workplaceId
            ], forDocument: calendarRef)
            
            // 3. 알바일 때 워커 서브컬렉션 등록
            if role == .worker, let workerDetail {
                let workerRef = workplaceRef.collection("worker").document(uid)
                do {
                    let workerData = try Firestore.Encoder().encode(workerDetail)
                    batch.setData(workerData, forDocument: workerRef)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
            }
            
            // 4. 사장이든 알바든 users/{uid}/workplace/{workplaceId}에 color 저장
            batch.setData([
                "color": color
            ], forDocument: userWorkplaceRef)
            
            batch.commit { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(workplaceId)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    /// 근무지의 worker 서브컬렉션에서 모든 알바(워커) 정보를 조회합니다.
    ///
    /// - Parameter workplaceId: 조회할 근무지의 Firestore documentID
    /// - Returns: WorkerDetailInfo 배열 (각 워커의 UID와 워커 상세 정보)
    /// - Firestore 경로: workplaces/{workplaceId}/worker
    func fetchWorkerListForWorkplace(workplaceId: String) -> Observable<[WorkerDetailInfo]> {
        let workerRef = db.collection("workplaces").document(workplaceId).collection("worker")
        return Observable.create { observer in
            let listener = workerRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let workers: [WorkerDetailInfo] = snapshot?.documents.compactMap { doc in
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: doc.data()),
                          let detail = try? JSONDecoder().decode(WorkerDetail.self, from: jsonData) else {
                        return nil
                    }
                    return WorkerDetailInfo(id: doc.documentID, detail: detail)
                } ?? []
                observer.onNext(workers)
            }
            return Disposables.create { listener.remove() }
        }
    }

    
    /// 월간 내 근무 이벤트 및 시급, 총 급여 반환
    /// - Parameters:
    ///   - uid: 유저 UID
    ///   - year: 연도
    ///   - month: 월
    /// - Returns: [WorkplaceWorkSummary] (근무지별 요약)
    func fetchMonthlyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummary]> {
        let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces")
        return Observable.create { observer in
            // 1. 상위 리스너 등록
            let mainListener = userWorkplaceRef.addSnapshotListener { snap, err in
                if let err = err {
                    observer.onError(err)
                    return
                }
                let ids = snap?.documents.map { $0.documentID } ?? []
                if ids.isEmpty {
                    observer.onNext([])
                    return
                }
                // 2. 각 근무지별로 Observable
                let perWorkplaceObservables = ids.map { workplaceId -> Observable<WorkplaceWorkSummary?> in
                    Observable<WorkplaceWorkSummary?>.create { o in
                        // 리스너 변수 선언 (옵셔널)
                        var workplaceListener: ListenerRegistration?
                        var workerListener: ListenerRegistration?
                        var calendarListener: ListenerRegistration?
                        var eventListener: ListenerRegistration?
                        
                        let workplaceDoc = self.db.collection("workplaces").document(workplaceId)
                        workplaceListener = workplaceDoc.addSnapshotListener { doc, _ in
                            guard let doc, let wData = doc.data(),
                                  let workplaceName = wData["workplacesName"] as? String else {
                                o.onNext(nil)
                                return
                            }
                            let workerDoc = workplaceDoc.collection("worker").document(uid)
                            workerListener = workerDoc.addSnapshotListener { workerDoc, _ in
                                guard let workerDoc, let wDetail = workerDoc.data(),
                                      let wage = wDetail["wage"] as? Int else {
                                    o.onNext(nil)
                                    return
                                }
                                let wageCalcMethod = wDetail["wageCalcMethod"] as? String ?? "hourly"
                                let payDay = wDetail["payDay"] as? Int
                                let payWeekday = wDetail["payWeekday"] as? String

                                let calendarQuery = self.db.collection("calendars").whereField("workplaceId", isEqualTo: workplaceId)
                                calendarListener = calendarQuery.addSnapshotListener { calSnap, _ in
                                    guard let calId = calSnap?.documents.first?.documentID else {
                                        o.onNext(nil)
                                        return
                                    }
                                    let eventQuery = self.db.collection("calendars").document(calId)
                                        .collection("events")
                                        .whereField("year", isEqualTo: year)
                                        .whereField("month", isEqualTo: month)
                                    eventListener = eventQuery.addSnapshotListener { evtSnap, _ in
                                        let events: [CalendarEvent] = evtSnap?.documents.compactMap { doc in
                                            do {
                                                let data = try JSONSerialization.data(withJSONObject: doc.data())
                                                let event = try JSONDecoder().decode(CalendarEvent.self, from: data)
                                                return event.createdBy == uid ? event : nil
                                            } catch { return nil }
                                        } ?? []
                                        let totalHours = events.reduce(0.0) { sum, event in
                                            sum + Self.calculateWorkedHours(start: event.startTime, end: event.endTime)
                                        }
                                        let totalWage: Int
                                        if wageCalcMethod == "monthly" {
                                            totalWage = wage
                                        } else {
                                            totalWage = Int(Double(wage) * totalHours)
                                        }
                                        o.onNext(WorkplaceWorkSummary(
                                            workplaceId: workplaceId,
                                            workplaceName: workplaceName,
                                            wage: wage,
                                            wageCalcMethod: wageCalcMethod,
                                            payDay: payDay,
                                            payWeekday: payWeekday,
                                            events: events,
                                            totalWage: totalWage
                                        ))
                                    }
                                }
                            }
                        }
                        // 리스너 해제
                        return Disposables.create {
                            eventListener?.remove()
                            calendarListener?.remove()
                            workerListener?.remove()
                            workplaceListener?.remove()
                        }
                    }
                }
                // zip 모든 근무지 요약 모으기 (매번 onNext)
                let zipDisposable = Observable.zip(perWorkplaceObservables)
                    .map { $0.compactMap { $0 } }
                    .subscribe(
                        onNext: { summaries in observer.onNext(summaries) },
                        onError: { error in observer.onError(error) }
                    )
            }
            // 최상위 리스너 해제
            return Disposables.create {
                mainListener.remove()
            }
        }
    }


    
    /// 일간 단위로 근무지별 근무 집계
    func fetchDailyWorkSummary(
        uid: String,
        year: Int,
        month: Int
    ) -> Observable<[WorkplaceWorkSummaryDaily]> {
        fetchMonthlyWorkSummary(uid: uid, year: year, month: month)
            .map { monthlySummaries in
                monthlySummaries.map { summary in
                    // 날짜별로 그룹화
                    let groupedByDay = Dictionary(grouping: summary.events) { $0.eventDate }
                    let dailySummary: [String: (events: [CalendarEvent], totalHours: Double, totalWage: Int)] = groupedByDay.mapValues { events in
                        let totalHours = events.reduce(0.0) { $0 + Self.calculateWorkedHours(start: $1.startTime, end: $1.endTime) }
                        let totalWage = Int(Double(summary.wage) * totalHours)
                        return (events, totalHours, totalWage)
                    }
                    return WorkplaceWorkSummaryDaily(
                        workplaceId: summary.workplaceId,
                        workplaceName: summary.workplaceName,
                        wage: summary.wage,
                        dailySummary: dailySummary
                    )
                }
            }
    }
    
    /// "09:00", "18:30" → Double(시간)
    private static func calculateWorkedHours(start: String, end: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let s = formatter.date(from: start),
              let e = formatter.date(from: end) else { return 0 }
        let diff = e.timeIntervalSince(s) / 3600
        return max(0, diff)
    }
    
    func deleteOrLeaveWorkplace(workplaceId: String, uid: String) -> Observable<Void> {
        print("[deleteOrLeaveWorkplace] called - workplaceId: \(workplaceId), uid: \(uid)")
        let workplaceObs = Observable<(ownerUid: String?, calendarId: String?)>.create { observer in
            self.db.collection("workplaces").document(workplaceId).getDocument { doc, error in
                if let error = error {
                    print("[deleteOrLeaveWorkplace] workplace getDocument error:", error)
                    observer.onError(error)
                } else {
                    let ownerUid = doc?.data()?["ownerId"] as? String
                    print("[deleteOrLeaveWorkplace] ownerUid:", ownerUid ?? "nil")
                    self.db.collection("calendars")
                        .whereField("workplaceId", isEqualTo: workplaceId)
                        .getDocuments { snap, err in
                            if let err = err {
                                print("[deleteOrLeaveWorkplace] calendars getDocuments error:", err)
                                observer.onError(err)
                            } else {
                                let calendarId = snap?.documents.first?.documentID
                                print("[deleteOrLeaveWorkplace] calendarId:", calendarId ?? "nil")
                                observer.onNext((ownerUid, calendarId))
                                observer.onCompleted()
                            }
                        }
                }
            }
            return Disposables.create()
        }
        
        return workplaceObs
            .flatMap { (ownerUid, calendarId) -> Observable<Void> in
                print("[deleteOrLeaveWorkplace] flatMap - ownerUid: \(ownerUid ?? "nil"), calendarId: \(calendarId ?? "nil")")
                // 오너 == 전체 삭제
                if ownerUid == uid {
                    print("[deleteOrLeaveWorkplace] I'm owner - call deleteWorkplaceAndReferences")
                    return self.deleteWorkplaceAndReferences(workplaceId: workplaceId, calendarId: calendarId)
                } else {
                    print("[deleteOrLeaveWorkplace] I'm worker - delete only my info/events/sharedWith")
                    let batch = self.db.batch()
                    
                    // 1. workplaces/{workplaceId}/worker/{myUid}
                    let workerRef = self.db.collection("workplaces").document(workplaceId)
                        .collection("worker").document(uid)
                    print("[deleteOrLeaveWorkplace] will delete workerRef:", workerRef.path)
                    batch.deleteDocument(workerRef)
                    
                    // 2. users/{myUid}/workplaces/{workplaceId}
                    let myWorkplaceRef = self.db.collection("users").document(uid)
                        .collection("workplaces").document(workplaceId)
                    print("[deleteOrLeaveWorkplace] will delete myWorkplaceRef:", myWorkplaceRef.path)
                    batch.deleteDocument(myWorkplaceRef)
                    
                    // 3. calendars/{calendarId}/events 중 내가 만든 이벤트만 삭제
                    if let calendarId = calendarId {
                        let eventsRef = self.db.collection("calendars").document(calendarId).collection("events")
                        let calendarRef = self.db.collection("calendars").document(calendarId)
                        print("[deleteOrLeaveWorkplace] will delete events created by me in calendarId:", calendarId)
                        return Observable.create { observer in
                            batch.commit { error in
                                if let error = error {
                                    print("[deleteOrLeaveWorkplace] batch commit error:", error)
                                    observer.onError(error)
                                } else {
                                    print("[deleteOrLeaveWorkplace] batch commit success. now updating sharedWith and deleting events...")
                                    // sharedWith 배열에서 uid 삭제
                                    calendarRef.updateData([
                                        "sharedWith": FieldValue.arrayRemove([uid])
                                    ]) { err in
                                        if let err = err {
                                            print("[deleteOrLeaveWorkplace] sharedWith arrayRemove error:", err)
                                            observer.onError(err)
                                            return
                                        }
                                        // (기존) 내가 만든 이벤트 삭제
                                        eventsRef.whereField("createdBy", isEqualTo: uid)
                                            .getDocuments { snap, err in
                                                if let err = err {
                                                    print("[deleteOrLeaveWorkplace] events getDocuments error:", err)
                                                    observer.onError(err)
                                                    return
                                                }
                                                let docs = snap?.documents ?? []
                                                print("[deleteOrLeaveWorkplace] will delete \(docs.count) events.")
                                                let group = DispatchGroup()
                                                docs.forEach { doc in
                                                    group.enter()
                                                    print("[deleteOrLeaveWorkplace] deleting event:", doc.documentID)
                                                    doc.reference.delete { _ in
                                                        group.leave()
                                                    }
                                                }
                                                group.notify(queue: .main) {
                                                    print("[deleteOrLeaveWorkplace] all events deleted")
                                                    observer.onNext(())
                                                    observer.onCompleted()
                                                }
                                            }
                                    }
                                }
                            }
                            return Disposables.create()
                        }
                    } else {
                        // 캘린더 없으면 batch만 처리
                        print("[deleteOrLeaveWorkplace] no calendarId, just commit batch")
                        return Observable.create { observer in
                            batch.commit { error in
                                if let error = error {
                                    print("[deleteOrLeaveWorkplace] batch commit error (no calendar):", error)
                                    observer.onError(error)
                                } else {
                                    print("[deleteOrLeaveWorkplace] batch commit success (no calendar)")
                                    observer.onNext(())
                                    observer.onCompleted()
                                }
                            }
                            return Disposables.create()
                        }
                    }
                }
            }
    }

    // 오너 전체 삭제
    private func deleteWorkplaceAndReferences(workplaceId: String, calendarId: String?) -> Observable<Void> {
        let workersRef = self.db.collection("workplaces").document(workplaceId).collection("worker")
        let workplaceRef = self.db.collection("workplaces").document(workplaceId)
        
        // 1. workers uid 모두 조회 (워커들)
        let deleteWorkersObs = Observable<[String]>.create { observer in
            workersRef.getDocuments { snapshot, error in
                if let error = error {
                    print("[deleteWorkplaceAndReferences] workers getDocuments error:", error)
                    observer.onError(error)
                    return
                }
                let workerDocs = snapshot?.documents ?? []
                var uids = workerDocs.map { $0.documentID }
                print("[deleteWorkplaceAndReferences] found workers uids:", uids)
                
                // 오너 uid도 포함 (workplace 문서에서 ownerId 가져옴)
                workplaceRef.getDocument { doc, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    if let ownerUid = doc?.data()?["ownerId"] as? String {
                        if !uids.contains(ownerUid) {
                            uids.append(ownerUid)
                        }
                        print("[deleteWorkplaceAndReferences] ownerUid also included:", ownerUid)
                    }
                    // worker 서브컬렉션 전체 삭제
                    let group = DispatchGroup()
                    workerDocs.forEach { doc in
                        group.enter()
                        print("[deleteWorkplaceAndReferences] deleting worker doc:", doc.documentID)
                        doc.reference.delete { _ in group.leave() }
                    }
                    group.notify(queue: .main) {
                        observer.onNext(uids)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
        
        // 2. 실제 삭제 진행
        return deleteWorkersObs.flatMap { uids -> Observable<Void> in
            let batch = self.db.batch()
            // workplaces 문서
            batch.deleteDocument(workplaceRef)
            print("[deleteWorkplaceAndReferences] will delete workplace:", workplaceRef.path)
            // 캘린더
            if let calendarId = calendarId {
                let calendarRef = self.db.collection("calendars").document(calendarId)
                batch.deleteDocument(calendarRef)
                print("[deleteWorkplaceAndReferences] will delete calendar:", calendarRef.path)
            }
            // users/{uid}/workplaces/{workplaceId} 모든 유저에 대해
            for uid in uids {
                let userWorkplaceRef = self.db.collection("users").document(uid)
                    .collection("workplaces").document(workplaceId)
                batch.deleteDocument(userWorkplaceRef)
                print("[deleteWorkplaceAndReferences] will delete userWorkplaceRef:", userWorkplaceRef.path)
            }
            // 커밋 + 캘린더 events 삭제
            return Observable.create { observer in
                batch.commit { error in
                    if let error = error {
                        print("[deleteWorkplaceAndReferences] batch commit error:", error)
                        observer.onError(error)
                    } else {
                        print("[deleteWorkplaceAndReferences] batch commit success")
                        // 캘린더 events 삭제
                        if let calendarId = calendarId {
                            let eventsRef = self.db.collection("calendars").document(calendarId).collection("events")
                            eventsRef.getDocuments { snapshot, error in
                                if let error = error {
                                    observer.onError(error)
                                    return
                                }
                                let docs = snapshot?.documents ?? []
                                let group = DispatchGroup()
                                docs.forEach { doc in
                                    group.enter()
                                    doc.reference.delete { _ in group.leave() }
                                }
                                group.notify(queue: .main) {
                                    observer.onNext(())
                                    observer.onCompleted()
                                }
                            }
                        } else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        }
    }



    
    /// 근무지/캘린더/색상/워커 정보를 수정합니다.
    /// - Parameters:
    ///   - workplaceId: 수정할 근무지 id
    ///   - calendarId: 연동된 캘린더 id (없으면 nil)
    ///   - uid: 현재 유저 uid
    ///   - role: .owner or .worker
    ///   - workplace: 수정할 근무지 정보(Workplace)
    ///   - workerDetail: 워커라면 워커 정보, 아니면 nil
    ///   - color: 변경할 색상값
    /// - Returns: 성공/실패 Observable<Void>
    func updateWorkplaceWithCalendarAndMaybeWorker(
        workplaceId: String,
        calendarId: String?,
        uid: String,
        role: Role,
        workplace: Workplace,
        workerDetail: WorkerDetail?,
        color: String
    ) -> Observable<Void> {
        let workplaceRef = db.collection("workplaces").document(workplaceId)
        let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces").document(workplaceId)
        let calendarRef: DocumentReference? = calendarId != nil ? db.collection("calendars").document(calendarId!) : nil

        return Observable.create { observer in
            let batch = self.db.batch()

            // 1. 근무지 정보 업데이트
            batch.updateData([
                "workplacesName": workplace.workplacesName,
                "category": workplace.category,
            ], forDocument: workplaceRef)

            // 2. 캘린더 정보 업데이트
            if let calendarRef = calendarRef {
                batch.updateData([
                    "calendarName": workplace.workplacesName,
                    // sharedWith 등 필요시 추가
                ], forDocument: calendarRef)
            }

            // 3. 워커라면 worker 서브컬렉션도 수정
            if role == .worker, let workerDetail {
                let workerRef = workplaceRef.collection("worker").document(uid)
                do {
                    let workerData = try Firestore.Encoder().encode(workerDetail)
                    batch.setData(workerData, forDocument: workerRef, merge: true)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
            }

            // 4. 색상도 수정
            batch.updateData([
                "color": color
            ], forDocument: userWorkplaceRef)

            batch.commit { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

}
