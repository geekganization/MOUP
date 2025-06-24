//
//  DummyNotificationService.swift
//  Routory
//
//  Created by shinyoungkim on 6/24/25.
//

import FirebaseFirestore
import RxSwift

/// NotificationService는 Firestore에 저장된 사용자, 근무지, 일정 데이터를 기반으로
/// 급여일 알림과 근무 시작 알림을 판단하고, 중복되지 않게 알림을 저장하는 서비스입니다.
final class DummyNotificationService {
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()

    /// 알림 파이프라인 실행 (사용자 UID 기준으로 전체 로직 시작)
    func runNotificationPipeline(uid: String) {
        fetchWorkplaceIds(for: uid)
            .asObservable()
            .flatMap { Observable.from($0) }
            .flatMap { workplaceId in
                self.fetchWorkerDetail(workplaceId: workplaceId, uid: uid)
                    .map { (workplaceId, $0) }
                    .asObservable()
            }
            .do(onNext: { (workplaceId, worker) in
                self.checkPaydayNotification(uid: uid, worker: worker)
            })
            .flatMap { (workplaceId, _) in
                self.fetchCalendarId(workplaceId: workplaceId)
                    .asObservable()
            }
            .flatMap { calendarId in
                self.checkTodayEventNotifications(uid: uid, calendarId: calendarId)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    /// 사용자의 workplace ID 목록을 조회
    private func fetchWorkplaceIds(for uid: String) -> Single<[String]> {
        return Single.create { single in
            self.db.collection("users").document(uid).collection("workplaces")
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        let ids = snapshot?.documents.map { $0.documentID } ?? []
                        single(.success(ids))
                    }
                }
            return Disposables.create()
        }
    }

    /// 근무지 내 사용자(worker)의 상세 정보를 조회
    private func fetchWorkerDetail(workplaceId: String, uid: String) -> Single<[String: Any]> {
        return Single.create { single in
            self.db.collection("workplaces").document(workplaceId)
                .collection("worker").document(uid)
                .getDocument { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    } else if let data = snapshot?.data() {
                        single(.success(data))
                    } else {
                        single(.failure(NSError(domain: "NoWorkerData", code: 0)))
                    }
                }
            return Disposables.create()
        }
    }

    /// 급여일 조건이 맞을 경우 알림을 생성
    private func checkPaydayNotification(uid: String, worker: [String: Any]) {
        guard let payDay = worker["payDay"] as? Int else { return }
        let reminder = worker["reminderBeforePayday"] as? Int ?? 3
        let today = Calendar.current.component(.day, from: Date())

        guard today == payDay - reminder else { return }

        let month = Calendar.current.component(.month, from: Date())
        let referenceId = "payday_2025_\(String(format: "%02d", month))"

        checkNotificationDuplicate(uid: uid, referenceId: referenceId)
            .subscribe(onSuccess: { isNew in
                if isNew {
                    self.sendNotification(uid: uid, referenceId: referenceId,
                                          title: "곧 급여일이에요!",
                                          body: "이번 달 급여일은 \(payDay)일입니다.",
                                          type: "payday_reminder")
                }
            })
            .disposed(by: disposeBag)
    }

    /// workplaceId에 해당하는 캘린더 ID 조회
    private func fetchCalendarId(workplaceId: String) -> Single<String> {
        return Single.create { single in
            self.db.collection("calendars")
                .whereField("workplaceId", isEqualTo: workplaceId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    } else if let id = snapshot?.documents.first?.documentID {
                        single(.success(id))
                    } else {
                        single(.failure(NSError(domain: "NoCalendar", code: 0)))
                    }
                }
            return Disposables.create()
        }
    }

    /// 오늘 날짜 기준으로 시작 1시간 전 이벤트에 대해 알림 판단 및 생성
    private func checkTodayEventNotifications(uid: String, calendarId: String) -> Completable {
        return Completable.create { completable in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let todayString = formatter.string(from: Date())

            self.db.collection("calendars").document(calendarId)
                .collection("events")
                .whereField("eventDate", isEqualTo: todayString)
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else {
                        completable(.completed)
                        return
                    }

                    let now = Date()
                    let nowMinutes = Calendar.current.component(.hour, from: now) * 60 + Calendar.current.component(.minute, from: now)

                    for doc in docs {
                        let data = doc.data()
                        guard let startTime = data["startTime"] as? String,
                              let title = data["title"] as? String,
                              let eventMinutes = self.toMinutes(timeString: startTime),
                              eventMinutes - nowMinutes == 60
                        else { continue }

                        let referenceId = "event_\(todayString.replacingOccurrences(of: ".", with: "_"))_\(startTime)"

                        self.checkNotificationDuplicate(uid: uid, referenceId: referenceId)
                            .subscribe(onSuccess: { isNew in
                                if isNew {
                                    self.sendNotification(uid: uid, referenceId: referenceId,
                                                          title: "근무 1시간 전 알림",
                                                          body: "\(title) 근무는 \(startTime)에 시작합니다.",
                                                          type: "work_event")
                                }
                            })
                            .disposed(by: self.disposeBag)
                    }

                    completable(.completed)
                }
            return Disposables.create()
        }
    }

    /// 동일한 referenceId의 알림이 이미 존재하는지 확인
    private func checkNotificationDuplicate(uid: String, referenceId: String) -> Single<Bool> {
        return Single.create { single in
            self.db.collection("users").document(uid)
                .collection("notifications")
                .whereField("referenceId", isEqualTo: referenceId)
                .getDocuments { snapshot, _ in
                    let isNew = snapshot?.documents.isEmpty ?? true
                    single(.success(isNew))
                }
            return Disposables.create()
        }
    }

    /// Firestore에 알림 생성
    private func sendNotification(uid: String, referenceId: String, title: String, body: String, type: String) {
        let ref = db.collection("users").document(uid).collection("notifications").document()
        let data: [String: Any] = [
            "title": title,
            "body": body,
            "referenceId": referenceId,
            "type": type,
            "createdAt": FieldValue.serverTimestamp(),
            "read": false
        ]
        ref.setData(data)
    }

    /// HH:mm 형식 문자열을 총 분으로 변환 (예: 09:30 → 570)
    private func toMinutes(timeString: String) -> Int? {
        let comps = timeString.split(separator: ":").compactMap { Int($0) }
        guard comps.count == 2 else { return nil }
        return comps[0] * 60 + comps[1]
    }
    
    /// 사용자 알림 목록을 가져옴
    func fetchUserNotifications(uid: String) -> Observable<[DummyNotification]> {
        return Observable.create { observer in
            self.db.collection("users").document(uid).collection("notifications")
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    let notifications: [DummyNotification] = snapshot?.documents.compactMap { doc in
                        let data = doc.data()

                        guard
                            let title = data["title"] as? String,
                            let body = data["body"] as? String,
                            let isRead = data["read"] as? Bool,
                            let timestamp = data["createdAt"] as? Timestamp,
                            let typeString = data["type"] as? String
                        else {
                            return nil
                        }

                        let timeAgo = DummyNotification.calculateTimeAgo(from: timestamp.dateValue())
                        let type: NotificationType

                        switch typeString {
                        case "approval_pending":
                            type = .approval(status: .pending)
                        case "approval_approved":
                            type = .approval(status: .approved)
                        case "approval_rejected":
                            type = .approval(status: .rejected)
                        default:
                            type = .common
                        }

                        return DummyNotification(isRead: isRead, title: title, content: body, time: timeAgo, type: type)
                    } ?? []

                    observer.onNext(notifications)
                    observer.onCompleted()
                }

            return Disposables.create()
        }
    }
}

extension DummyNotification {
    static func calculateTimeAgo(from date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))

        if secondsAgo < 60 {
            return "\(secondsAgo)초 전"
        } else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)분 전"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)시간 전"
        } else {
            return "\(secondsAgo / 86400)일 전"
        }
    }
}
