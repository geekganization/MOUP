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
    func updateWorkerDetail(
        workplaceId: String,
        uid: String,
        workerDetail: WorkerDetail
    ) -> Observable<Void>
    func updateWorkplaceNameCategoryAndColor(
        workplaceId: String,
        name: String,
        category: String,
        uid: String,
        color: String
    ) -> Observable<Void>
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
            self.db.collection("workplaces")
                .whereField("inviteCode", isEqualTo: inviteCode)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    guard let document = snapshot?.documents.first else {
                        observer.onNext(nil)
                        observer.onCompleted()
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
                    observer.onCompleted()
                }
            return Disposables.create()
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
        let userWorkplaceRef = db.collection("users").document(uid).collection("workplaces")
        return Observable<[String]>.create { observer in
            let listener = userWorkplaceRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let ids = snapshot?.documents.map { $0.documentID } ?? []
                observer.onNext(ids)
            }
            return Disposables.create { listener.remove() }
        }
        .flatMapLatest { ids -> Observable<[WorkplaceInfo]> in
            if ids.isEmpty {
                return Observable.just([])
            }
            let db = Firestore.firestore()
            let observables: [Observable<WorkplaceInfo?>] = ids.map { workplaceId in
                Observable<WorkplaceInfo?>.create { detailObserver in
                    db.collection("workplaces").document(workplaceId).getDocument { doc, error in
                        if let doc = doc, let data = doc.data() {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: data)
                                let workplace = try JSONDecoder().decode(Workplace.self, from: jsonData)
                                detailObserver.onNext(WorkplaceInfo(id: workplaceId, workplace: workplace))
                                detailObserver.onCompleted()
                            } catch {
                                detailObserver.onError(error)
                            }
                        } else {
                            detailObserver.onNext(nil)
                            detailObserver.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            return Observable.zip(observables).map { $0.compactMap { $0 } }
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
            
            batch.setData([
                "workplacesName": workplace.workplacesName,
                "category": workplace.category,
                "ownerId": workplace.ownerId,
                "inviteCode": workplace.inviteCode,
                "isOfficial": (role == .owner)
            ], forDocument: workplaceRef)
            
            batch.setData([
                "calendarName": workplace.workplacesName,
                "isShared": (role == .owner),
                "ownerId": uid,
                "sharedWith": [],
                "workplaceId": workplaceId
            ], forDocument: calendarRef)
            
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
            workerRef.getDocuments { snapshot, error in
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
                observer.onCompleted()
            }
            return Disposables.create()
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
            var listeners: [ListenerRegistration] = []
            var summariesDict: [String: WorkplaceWorkSummary] = [:]
            let dispatchGroup = DispatchGroup()

            userWorkplaceRef.getDocuments { snap, err in
                if let err = err {
                    observer.onError(err)
                    return
                }

                let ids = snap?.documents.map { $0.documentID } ?? []
                if ids.isEmpty {
                    observer.onNext([])
                    observer.onCompleted()
                    return
                }

                for workplaceId in ids {
                    dispatchGroup.enter()

                    let workplaceDoc = self.db.collection("workplaces").document(workplaceId)
                    workplaceDoc.getDocument { doc, _ in
                        guard let doc, let wData = doc.data(),
                              let workplaceName = wData["workplacesName"] as? String else {
                            dispatchGroup.leave()
                            return
                        }

                        workplaceDoc.collection("worker").document(uid).getDocument { workerDoc, _ in
                            guard let workerDoc, let wDetail = workerDoc.data(),
                                  let wage = wDetail["wage"] as? Int else {
                                dispatchGroup.leave()
                                return
                            }

                            let wageCalcMethod = wDetail["wageCalcMethod"] as? String ?? "hourly"
                            let payDay = wDetail["payDay"] as? Int
                            let payWeekday = wDetail["payWeekday"] as? String

                            self.db.collection("calendars")
                                .whereField("workplaceId", isEqualTo: workplaceId)
                                .getDocuments { calSnap, _ in
                                    guard let calId = calSnap?.documents.first?.documentID else {
                                        dispatchGroup.leave()
                                        return
                                    }

                                    let eventsRef = self.db.collection("calendars")
                                        .document(calId)
                                        .collection("events")
                                        .whereField("year", isEqualTo: year)
                                        .whereField("month", isEqualTo: month)

                                    let listener = eventsRef.addSnapshotListener { evtSnap, _ in
                                        let events: [CalendarEvent] = evtSnap?.documents.compactMap { doc in
                                            do {
                                                let data = try JSONSerialization.data(withJSONObject: doc.data())
                                                let event = try JSONDecoder().decode(CalendarEvent.self, from: data)
                                                return event.createdBy == uid ? event : nil
                                            } catch {
                                                return nil
                                            }
                                        } ?? []

                                        let totalHours = events.reduce(0.0) {
                                            $0 + WageHelper.calculateWorkedHours(start: $1.startTime, end: $1.endTime)
                                        }

                                        let totalWage: Int = (wageCalcMethod == "고정") ? wage : Int(Double(wage) * totalHours)

                                        let summary = WorkplaceWorkSummary(
                                            workplaceId: workplaceId,
                                            workplaceName: workplaceName,
                                            wage: wage,
                                            wageCalcMethod: wageCalcMethod,
                                            payDay: payDay,
                                            payWeekday: payWeekday,
                                            events: events,
                                            totalWage: totalWage
                                        )

                                        summariesDict[workplaceId] = summary
                                        observer.onNext(Array(summariesDict.values))
                                    }

                                    listeners.append(listener)
                                    dispatchGroup.leave()
                                }
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    observer.onNext(Array(summariesDict.values))
                }
            }

            return Disposables.create {
                listeners.forEach { $0.remove() }
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
                        let totalHours = events.reduce(0.0) { $0 + WageHelper.calculateWorkedHours(start: $1.startTime, end: $1.endTime) }
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
    
    func deleteOrLeaveWorkplace(workplaceId: String, uid: String) -> Observable<Void> {
        // 1. 근무지 owner, 캘린더 id 조회
        let workplaceObs = Observable<(ownerUid: String?, calendarId: String?)>.create { observer in
            self.db.collection("workplaces").document(workplaceId).getDocument { doc, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    let ownerUid = doc?.data()?["ownerId"] as? String
                    self.db.collection("calendars")
                        .whereField("workplaceId", isEqualTo: workplaceId)
                        .getDocuments { snap, err in
                            if let err = err {
                                observer.onError(err)
                            } else {
                                let calendarId = snap?.documents.first?.documentID
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
                // 오너 == 전체 삭제
                if ownerUid == uid {
                    return self.deleteWorkplaceAndReferences(workplaceId: workplaceId, calendarId: calendarId, ownerUid: ownerUid)
                } else {
                    // 워커 == 내 정보, 내가 만든 이벤트만 삭제 + 내 workplaces 문서도 삭제 + sharedWith에서 uid 삭제
                    let batch = self.db.batch()
                    
                    // 1. workplaces/{workplaceId}/worker/{myUid}
                    let workerRef = self.db.collection("workplaces").document(workplaceId)
                        .collection("worker").document(uid)
                    batch.deleteDocument(workerRef)
                    
                    // 2. users/{myUid}/workplaces/{workplaceId} (내 workplaces 문서 삭제)
                    let myWorkplaceRef = self.db.collection("users").document(uid)
                        .collection("workplaces").document(workplaceId)
                    batch.deleteDocument(myWorkplaceRef)
                    
                    // 3. calendars/{calendarId}/events 중 내가 만든(createdBy == myUid) 이벤트만 삭제
                    if let calendarId = calendarId {
                        let eventsRef = self.db.collection("calendars").document(calendarId).collection("events")
                        let calendarRef = self.db.collection("calendars").document(calendarId)
                        return Observable.create { observer in
                            print("batch.commit 호출 전")
                            batch.commit { error in
                                if let error = error {
                                    print("batch.commit 에러:", error)
                                    observer.onError(error)
                                } else {
                                    print("batch.commit 성공, sharedWith arrayRemove 실행")
                                    // 3-1. sharedWith에서 uid 제거
                                    calendarRef.updateData([
                                        "sharedWith": FieldValue.arrayRemove([uid])
                                    ]) { err in
                                        if let err = err {
                                            print("sharedWith arrayRemove 에러:", err)
                                            observer.onError(err)
                                            return
                                        }
                                        print("sharedWith arrayRemove 성공, 내가 만든 이벤트 삭제 시도")
                                        // 3-2. 내가 만든 이벤트 삭제
                                        eventsRef.whereField("createdBy", isEqualTo: uid)
                                            .getDocuments { snap, err in
                                                if let err = err {
                                                    print("내가 만든 이벤트 getDocuments 에러:", err)
                                                    observer.onError(err)
                                                    return
                                                }
                                                let docs = snap?.documents ?? []
                                                print("내가 만든 이벤트 개수:", docs.count)
                                                let group = DispatchGroup()
                                                docs.forEach { doc in
                                                    group.enter()
                                                    doc.reference.delete { _ in
                                                        group.leave()
                                                    }
                                                }
                                                group.notify(queue: .main) {
                                                    print("내가 만든 이벤트 전부 삭제 완료")
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
                        return Observable.create { observer in
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
            }
    }
    
    // 오너 전체 삭제
    private func deleteWorkplaceAndReferences(
        workplaceId: String,
        calendarId: String?,
        ownerUid: String?
    ) -> Observable<Void> {
        // 1. workers 서브컬렉션 모든 문서 삭제 + uid 목록 수집
        let workersRef = self.db.collection("workplaces").document(workplaceId).collection("worker")
        let deleteWorkersObs = Observable<[String]>.create { observer in
            workersRef.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let workerDocs = snapshot?.documents ?? []
                let uids = workerDocs.map { $0.documentID }
                let group = DispatchGroup()
                for doc in workerDocs {
                    group.enter()
                    doc.reference.delete { _ in group.leave() }
                }
                group.notify(queue: .main) {
                    observer.onNext(uids)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }

        // 2. workers 삭제 후, workplace/캘린더/유저 workplaces 문서/이벤트 삭제
        return deleteWorkersObs.flatMap { uids -> Observable<Void> in
            let batch = self.db.batch()
            
            // workplaces/{workplaceId}
            let workplaceRef = self.db.collection("workplaces").document(workplaceId)
            batch.deleteDocument(workplaceRef)
            
            // calendars/{calendarId}
            if let calendarId = calendarId {
                let calendarRef = self.db.collection("calendars").document(calendarId)
                batch.deleteDocument(calendarRef)
            }
            
            // users/{uid}/workplaces/{workplaceId} (모든 워커+오너의 workplaces 문서 삭제)
            var allUids = uids
            if let ownerUid = ownerUid, !uids.contains(ownerUid) {
                allUids.append(ownerUid)
            }
            for uid in allUids {
                let userWorkplaceRef = self.db.collection("users").document(uid)
                    .collection("workplaces").document(workplaceId)
                batch.deleteDocument(userWorkplaceRef)
            }
            
            // batch commit → 이후 events 서브컬렉션 삭제
            return Observable.create { observer in
                batch.commit { error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        // 캘린더 events 서브컬렉션 삭제 (있을 때만)
                        if let calendarId = calendarId {
                            let eventsRef = self.db.collection("calendars").document(calendarId).collection("events")
                            eventsRef.getDocuments { snapshot, error in
                                if let error = error {
                                    observer.onError(error)
                                    return
                                }
                                let group = DispatchGroup()
                                for doc in snapshot?.documents ?? [] {
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


    
    func updateWorkerDetail(
        workplaceId: String,
        uid: String,
        workerDetail: WorkerDetail
    ) -> Observable<Void> {
        let workerRef = db.collection("workplaces").document(workplaceId)
            .collection("worker").document(uid)
        
        return Observable.create { observer in
            do {
                let workerData = try Firestore.Encoder().encode(workerDetail)
                workerRef.setData(workerData, merge: true) { error in
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
    
    
    func updateWorkplaceNameCategoryAndColor(
        workplaceId: String,
        name: String,
        category: String,
        uid: String,
        color: String
    ) -> Observable<Void> {
        let workplaceRef = db.collection("workplaces").document(workplaceId)
        let userWorkplaceRef = db.collection("users").document(uid)
            .collection("workplaces").document(workplaceId)
        let calendarsRef = db.collection("calendars")
        
        return Observable.create { observer in
            // 1. 먼저 calendars 컬렉션에서 workplaceId로 해당 캘린더 찾기
            calendarsRef.whereField("workplaceId", isEqualTo: workplaceId).getDocuments { snap, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                let batch = self.db.batch()
                
                // 1) workplaces/{workplaceId} 이름, 카테고리 업데이트
                batch.updateData([
                    "workplacesName": name,
                    "category": category
                ], forDocument: workplaceRef)
                
                // 2) users/{uid}/workplaces/{workplaceId} 색상 업데이트
                batch.setData(["color": color], forDocument: userWorkplaceRef, merge: true)
                
                // 3) calendars에서 찾은 문서의 calendarName 업데이트
                snap?.documents.forEach { doc in
                    let calendarRef = calendarsRef.document(doc.documentID)
                    batch.updateData([
                        "calendarName": name
                    ], forDocument: calendarRef)
                }
                
                batch.commit { error in
                    if let error = error as NSError? {
                        if error.domain == FirestoreErrorDomain,
                           error.code == FirestoreErrorCode.permissionDenied.rawValue {
                            observer.onError(
                                NSError(
                                    domain: "CustomErrorDomain",
                                    code: error.code,
                                    userInfo: [
                                        NSLocalizedDescriptionKey: "권한이 없습니다. Firestore Security Rule에 의해 거부되었습니다."
                                    ]
                                )
                            )
                        } else {
                            observer.onError(error)
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
