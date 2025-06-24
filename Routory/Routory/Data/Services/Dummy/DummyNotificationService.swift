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
    /// - 사용자의 근무지 정보를 기반으로 급여일 알림 및 근무 1시간 전 알림을 판단하여 Firestore에 저장하는 비동기 파이프라인입니다.
    /// - 내부적으로 다음 순서로 동작합니다:
    ///   1. 사용자가 속한 workplace ID 목록 조회
    ///   2. 각 workplace에서 사용자의 근무 정보(workerDetail) 조회
    ///   3. 근무 정보로 급여일 알림 조건 판단 및 생성
    ///   4. 각 workplace에 대응하는 calendarId 조회
    ///   5. calendarId에 해당하는 오늘 날짜 이벤트 중 시작 1시간 전 이벤트에 대해 알림 생성
    ///
    /// - Parameter uid: 현재 로그인한 사용자 UID
    func runNotificationPipeline(uid: String) {
        // 1. 사용자의 workplace ID 목록 조회
        fetchWorkplaceIds(for: uid)
            .asObservable()
            
            // 2. 각 workplace ID에 대해 반복적으로 workerDetail 정보 조회
            .flatMap { Observable.from($0) }
            .flatMap { workplaceId in
                self.fetchWorkerDetail(workplaceId: workplaceId, uid: uid)
                    .map { (workplaceId, $0) } // workerDetail과 workplaceId를 튜플로 묶음
                    .asObservable()
            }
            
            // 3. 각 workerDetail에 대해 급여일 알림 조건 검사 및 알림 생성 시도
            .do(onNext: { (workplaceId, worker) in
                self.checkPaydayNotification(uid: uid, worker: worker)
            })
            
            // 4. 각 workplace에 해당하는 calendarId 조회
            .flatMap { (workplaceId, _) in
                self.fetchCalendarId(workplaceId: workplaceId)
                    .asObservable()
            }
            
            // 5. calendarId 기반으로 오늘 날짜 이벤트 조회 및 1시간 전 알림 조건 검사
            .flatMap { calendarId in
                self.checkTodayEventNotifications(uid: uid, calendarId: calendarId)
                    .andThen(Observable.just(())) // Completable → Observable 변환
            }
            
            // 6. 최종 subscribe로 파이프라인 실행
            .subscribe()
            .disposed(by: disposeBag)
    }

    /// 사용자의 workplace ID 목록을 조회합니다.
    /// - 이 함수는 Firebase Firestore에서 지정된 사용자의 하위 컬렉션 `/users/{uid}/workplaces`를 조회하고,
    ///   해당 컬렉션 내의 문서 ID들을 추출하여 반환합니다.
    /// - 각 문서의 ID는 사용자가 속한 workplace의 고유 식별자입니다.
    /// - 결과는 RxSwift의 `Single<[String]>`로 감싸져 비동기적으로 반환되며, 성공 시 workplace ID 배열을 방출하고 실패 시 에러를 전달합니다.
    ///
    /// - Parameter uid: 조회할 사용자의 UID (Firebase Authentication 기준)
    /// - Returns: Single<[String]> — workplace 문서 ID(=workplaceId)의 배열을 담고 있는 RxSwift Single
    private func fetchWorkplaceIds(for uid: String) -> Single<[String]> {
        return Single.create { single in
            // Firestore 경로: users/{uid}/workplaces 하위 컬렉션 접근
            self.db.collection("users").document(uid).collection("workplaces")
                .getDocuments { snapshot, error in
                    if let error = error {
                        // 쿼리 실패 시 에러를 전달
                        single(.failure(error))
                    } else {
                        // 문서 목록을 가져와서 documentID(=workplaceId) 배열로 변환
                        let ids = snapshot?.documents.map { $0.documentID } ?? []
                        // 성공적으로 배열 반환
                        single(.success(ids))
                    }
                }

            // 메모리 해제를 위한 Disposable 반환
            return Disposables.create()
        }
    }

    /// 특정 근무지(workplace) 내의 사용자(worker) 상세 정보를 조회합니다.
    /// - 이 함수는 Firestore에서 다음 경로에 접근하여 데이터를 조회합니다: `/workplaces/{workplaceId}/worker/{uid}`
    /// - 해당 경로는 특정 근무지 내에 속한 근로자의 정보가 저장된 위치입니다.
    /// - 반환되는 데이터는 [String: Any] 딕셔너리 형태이며, 일반적으로 근무자 이름, 급여일, 알림 설정 등 다양한 필드를 포함합니다.
    /// - RxSwift의 `Single<[String: Any]>`로 감싸져 있어, 성공 시 한 번만 데이터를 방출하고 종료됩니다.
    /// - 문서가 존재하지 않거나 오류가 발생하면 실패(`.failure`)로 처리됩니다.
    ///
    /// - Parameters:
    ///   - workplaceId: 조회 대상 근무지의 고유 ID
    ///   - uid: 근무자(사용자)의 UID (Firebase Authentication 기준)
    /// - Returns: Single<[String: Any]> — 근무자 정보가 담긴 딕셔너리를 방출하는 RxSwift Single
    private func fetchWorkerDetail(workplaceId: String, uid: String) -> Single<[String: Any]> {
        return Single.create { single in
            // Firestore 경로: /workplaces/{workplaceId}/worker/{uid}
            self.db.collection("workplaces").document(workplaceId)
                .collection("worker").document(uid)
                .getDocument { snapshot, error in
                    if let error = error {
                        // Firestore 쿼리 실패 시 에러 반환
                        single(.failure(error))
                    } else if let data = snapshot?.data() {
                        // 문서가 존재하고 데이터가 존재하는 경우 성공 반환
                        single(.success(data))
                    } else {
                        // 문서는 존재하지만 데이터가 없는 경우 (예외적 상황)
                        single(.failure(NSError(domain: "NoWorkerData", code: 0)))
                    }
                }

            // 메모리 해제를 위한 Disposable 반환
            return Disposables.create()
        }
    }

    /// 근무자의 급여일 정보와 현재 날짜를 비교하여, 알림을 보낼 시점이면 Firestore에 알림을 생성합니다.
    /// - 이 함수는 사용자의 근무 정보(worker dict)에서 `payDay`와 `reminderBeforePayday` 값을 추출하여
    ///   오늘이 "급여일 - 사전알림일수"에 해당하는 경우에만 알림을 생성합니다.
    /// - 알림은 동일한 월에 중복되지 않도록 `referenceId`를 기준으로 중복 체크 후 생성됩니다.
    ///
    /// - Parameters:
    ///   - uid: Firebase 사용자 고유 식별자 (알림 저장 시 사용)
    ///   - worker: 근무자 상세 정보가 담긴 딕셔너리. `payDay`, `reminderBeforePayday` 등의 키를 포함해야 함.
    private func checkPaydayNotification(uid: String, worker: [String: Any]) {
        // 근무자의 급여일(payDay)을 가져옵니다. (예: 매월 25일)
        guard let payDay = worker["payDay"] as? Int else { return }

        // 급여일 며칠 전에 알림을 줄지에 대한 설정값. 없으면 기본값 3일 전.
        let reminder = worker["reminderBeforePayday"] as? Int ?? 3

        // 오늘 날짜의 일(day)만 추출 (예: 6월 22일 → 22)
        let today = Calendar.current.component(.day, from: Date())

        // 오늘이 (급여일 - 사전알림일수)와 일치하지 않으면 종료
        guard today == payDay - reminder else { return }

        // referenceId는 월별 알림 중복 생성을 방지하기 위한 고유값
        let month = Calendar.current.component(.month, from: Date())
        let referenceId = "payday_2025_\(String(format: "%02d", month))"

        // 이미 동일 referenceId의 알림이 있는지 Firestore에서 확인
        checkNotificationDuplicate(uid: uid, referenceId: referenceId)
            .subscribe(onSuccess: { isNew in
                if isNew {
                    // 중복이 아니라면 Firestore에 알림 데이터를 저장
                    self.sendNotification(
                        uid: uid,
                        referenceId: referenceId,
                        title: "급여알림",
                        body: "이번주는 급여일이에요!\n총 예상 급여는\(payDay)원이에요!",
                        type: "payday_reminder"
                    )
                }
            })
            .disposed(by: disposeBag)
    }

    /// 지정된 근무지(workplaceId)에 연결된 캘린더 문서를 Firestore에서 조회하고,
    /// 해당 문서의 ID를 반환합니다.
    ///
    /// - 이 메서드는 `calendars` 컬렉션에서 `workplaceId` 필드가 전달된 값과 일치하는 문서를 찾습니다.
    /// - 첫 번째로 일치하는 문서의 documentID(=calendarId)를 반환합니다.
    /// - 만약 일치하는 문서가 없거나, 쿼리에 실패할 경우 에러를 반환합니다.
    ///
    /// - Parameter workplaceId: 캘린더와 연결된 근무지의 고유 ID
    /// - Returns: 캘린더 document의 ID를 포함한 `Single<String>`
    ///   (성공 시 캘린더 ID, 실패 시 `NoCalendar` 또는 Firestore 오류 반환)
    private func fetchCalendarId(workplaceId: String) -> Single<String> {
        return Single.create { single in
            self.db.collection("calendars")
                // 필드 'workplaceId'가 주어진 값과 동일한 문서 필터링
                .whereField("workplaceId", isEqualTo: workplaceId)
                .getDocuments { snapshot, error in
                    // Firestore 쿼리 중 에러가 발생한 경우 에러 반환
                    if let error = error {
                        single(.failure(error))
                    }
                    // 쿼리 결과에서 첫 번째 문서가 존재할 경우, 해당 문서의 ID 반환
                    else if let id = snapshot?.documents.first?.documentID {
                        single(.success(id))
                    }
                    // 쿼리 결과가 비어있거나 문서가 없는 경우 사용자 정의 에러 반환
                    else {
                        single(.failure(NSError(domain: "NoCalendar", code: 0)))
                    }
                }
            // Observable 생명주기 종료 처리를 위한 disposable 반환
            return Disposables.create()
        }
    }

    /// 오늘 날짜 기준으로 등록된 근무 이벤트 중 "시작 1시간 전"인 이벤트에 대해 알림을 생성합니다.
    /// 이 함수는 사용자의 알림 중복 여부를 확인하고, 중복되지 않은 경우에만 알림을 Firestore에 저장합니다.
    ///
    /// - 예: 현재 시간이 08:00일 때, 09:00에 시작하는 근무 이벤트가 있다면 알림을 생성합니다.
    ///
    /// - Parameter uid: 사용자 고유 ID
    /// - Parameter calendarId: 사용자의 근무 일정이 저장된 캘린더 문서 ID
    /// - Returns: `Completable` – 완료 또는 에러 없이 단순 실행 여부를 리턴 (구독은 `.subscribe()`로 처리)
    private func checkTodayEventNotifications(uid: String, calendarId: String) -> Completable {
        return Completable.create { completable in
            // 1. 오늘 날짜 문자열 생성 ("yyyy.MM.dd" 형식, 예: 2025.06.24)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let todayString = formatter.string(from: Date())

            // 2. 캘린더 → events 서브컬렉션에서 오늘 날짜의 이벤트 목록을 조회
            self.db.collection("calendars").document(calendarId)
                .collection("events")
                .whereField("eventDate", isEqualTo: todayString)
                .getDocuments { snapshot, error in
                    // 문서 조회 실패 또는 이벤트 없음 → 그냥 완료 처리
                    guard let docs = snapshot?.documents else {
                        completable(.completed)
                        return
                    }

                    // 3. 현재 시간을 분 단위로 환산 (예: 08:30 → 510)
                    let now = Date()
                    let nowMinutes = Calendar.current.component(.hour, from: now) * 60 +
                                     Calendar.current.component(.minute, from: now)

                    // 4. 조회된 이벤트 각각에 대해 처리
                    for doc in docs {
                        let data = doc.data()

                        // 필요한 필드 추출: 시작 시간, 제목
                        guard let startTime = data["startTime"] as? String,
                              let title = data["title"] as? String,
                              let eventMinutes = self.toMinutes(timeString: startTime),
                              eventMinutes - nowMinutes <= 60 && eventMinutes - nowMinutes > 0
                        else {
                            continue // 조건 미충족 시 무시
                        }

                        // 5. 알림의 고유 식별자(referenceId) 생성 (날짜+시간 기반)
                        let referenceId = "event_\(todayString.replacingOccurrences(of: ".", with: "_"))_\(startTime)"

                        // 6. 동일한 referenceId의 알림이 이미 존재하는지 확인
                        self.checkNotificationDuplicate(uid: uid, referenceId: referenceId)
                            .subscribe(onSuccess: { isNew in
                                if isNew {
                                    // 중복이 아닐 경우 알림 저장
                                    self.sendNotification(
                                        uid: uid,
                                        referenceId: referenceId,
                                        title: "근무알림",
                                        body: "오늘 \(startTime)시부터 \(title)에서\n근무가 있어요. 준비되셨나요?",
                                        type: "work_event"
                                    )
                                }
                            })
                            .disposed(by: self.disposeBag)
                    }

                    // 7. 모든 로직이 끝난 뒤 완료 처리 (성공이든 조건 미충족이든)
                    completable(.completed)
                }

            // 8. Completable 생명주기 관리용 Disposable 반환
            return Disposables.create()
        }
    }

    /// Firestore에 동일한 referenceId를 가진 알림이 이미 존재하는지 확인합니다.
    /// 이 함수는 알림 중복 생성을 방지하기 위해 사용됩니다.
    ///
    /// - Parameter uid: 사용자 고유 ID (Firestore의 "users/{uid}" 문서를 기준으로 탐색)
    /// - Parameter referenceId: 알림 고유 식별자 (예: "payday_2025_06", "event_2025_06_24_09:00")
    /// - Returns: `Single<Bool>` – true: 중복 없음(새로 생성 가능), false: 이미 존재(생성 안 함)
    private func checkNotificationDuplicate(uid: String, referenceId: String) -> Single<Bool> {
        return Single.create { single in
            // "users/{uid}/notifications" 경로에서 referenceId가 일치하는 문서가 있는지 쿼리
            self.db.collection("users").document(uid)
                .collection("notifications")
                .whereField("referenceId", isEqualTo: referenceId)
                .getDocuments { snapshot, _ in
                    // 쿼리 결과가 비어 있으면 -> 중복 알림 없음 -> 새로 생성 가능
                    // 쿼리 결과가 존재하면 -> 이미 해당 알림이 있음 -> 생성 방지
                    let isNew = snapshot?.documents.isEmpty ?? true
                    single(.success(isNew))
                }

            // Disposable 반환: Firestore 쿼리 취소 시 메모리 해제 용도
            return Disposables.create()
        }
    }

    /// 주어진 파라미터로 사용자 알림을 Firestore에 저장합니다.
    /// - 사용 경로:  users/{uid}/notifications/{autoId}
    /// - 문서 구조:
    ///   ├── title        : 알림 제목 (예: “근무 1시간 전 알림”)
    ///   ├── body         : 알림 본문(상세 메시지)
    ///   ├── referenceId  : 중복 방지용 고유 ID (payday_xxx, event_xxx 등)
    ///   ├── type         : 알림 분류 코드 (payday_reminder, work_event …)
    ///   ├── createdAt    : 서버 타임스탬프(FieldValue.serverTimestamp()) ― 정렬·기간 계산용
    ///   └── read         : 읽음 여부(최초 false -> 읽으면 true 로 업데이트)
    ///
    /// - Parameters:
    ///   - uid         : 알림을 저장할 사용자 문서 ID
    ///   - referenceId : 중복 여부 판별용 고유 키
    ///   - title       : 사용자에게 노출할 알림 제목
    ///   - body        : 사용자에게 노출할 알림 내용
    ///   - type        : 알림 카테고리(비즈니스 로직 구분용)
    private func sendNotification(
        uid: String,
        referenceId: String,
        title: String,
        body: String,
        type: String
    ) {
        // 알림을 저장할 경로 생성 → users/{uid}/notifications/새로운 문서
        let ref = db.collection("users")
                    .document(uid)
                    .collection("notifications")
                    .document()          // 자동 생성 ID
        
        // Firestore에 저장할 필드 정의
        let data: [String: Any] = [
            "title":       title,                        // 알림 제목
            "body":        body,                         // 알림 본문
            "referenceId": referenceId,                  // 중복 체크용
            "type":        type,                         // 알림 카테고리
            "createdAt":   FieldValue.serverTimestamp(), // 서버 기준 생성 시각
            "read":        false                         // 최초 생성 시 미읽음 상태
        ]
        
        // 문서에 데이터 쓰기(에러 처리는 필요 시 .setData(_,completion:) 활용)
        ref.setData(data)
    }

    /// “HH:mm” 형식의 시‧분 문자열을 “총 분(minute)” 단위로 변환합니다.
    /// - 예)  "09:30"  →  9 × 60 + 30 = **570**
    /// - 예)  "18:00"  →  18 × 60 + 0 = **1080**
    ///
    /// - Parameter timeString: 24시간제 시각 문자열.
    ///   ‣ 반드시 `:`(콜론)으로 시‧분이 구분된 두 자리 또는 한 자리 숫자여야 합니다.
    ///   ‣ 허용 예: `"7:05"`, `"07:05"`, `"23:59"`
    ///   ‣ 잘못된 예: `"7-05"`, `"0705"`, `"24:00"`
    ///
    /// - Returns:
    ///   `Int?` — 성공 시 시‧분을 분 단위로 환산한 값,
    ///   형식이 잘못됐거나 숫자 변환에 실패하면 `nil`.
    private func toMinutes(timeString: String) -> Int? {
        
        // "HH:mm" → ["HH", "mm"] 분리 후 Int로 변환
        let comps = timeString
            .split(separator: ":")     // ["HH", "mm"]
            .compactMap { Int($0) }    // [Int] 변환
        
        // 시‧분 두 값이 모두 존재해야 유효
        guard comps.count == 2 else { return nil }
        
        // (시 * 60) + 분  → 총 분(minute) 값 반환
        return comps[0] * 60 + comps[1]
    }
    
    /// Firestore에서 특정 사용자의 알림 목록을 불러와 `DummyNotification` 배열로 반환합니다.
    /// 알림은 생성 시간(createdAt)을 기준으로 내림차순 정렬되며, 각 문서를 `DummyNotification` 모델로 매핑합니다.
    /// 실패 시에는 에러를 방출하고, 성공 시에는 알림 배열을 `.onNext`로 전달한 후 `.onCompleted`로 종료합니다.
    ///
    /// - Parameter uid: 알림을 가져올 사용자의 UID (고유 식별자)
    /// - Returns: `[DummyNotification]`을 방출하는 Observable 스트림
    func fetchUserNotifications(uid: String) -> Observable<[DummyNotification]> {
        return Observable.create { observer in
            // Firestore에서 해당 사용자의 알림 컬렉션 조회
            self.db.collection("users").document(uid).collection("notifications")
                .order(by: "createdAt", descending: true) // 최근 알림부터 정렬
                .getDocuments { snapshot, error in
                    // 에러 발생 시 스트림 종료
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    // Firestore 문서 배열을 DummyNotification 배열로 변환
                    let notifications: [DummyNotification] = snapshot?.documents.compactMap { doc in
                        let data = doc.data()

                        // 필수 필드 파싱 (모두 존재해야 유효한 알림으로 간주)
                        guard
                            let title = data["title"] as? String,
                            let body = data["body"] as? String,
                            let isRead = data["read"] as? Bool,
                            let timestamp = data["createdAt"] as? Timestamp,
                            let typeString = data["type"] as? String
                        else {
                            return nil // 필드가 누락된 경우 스킵
                        }

                        // 시간 표시 포맷팅 (예: "3분 전")
                        let timeAgo = DummyNotification.calculateTimeAgo(from: timestamp.dateValue())

                        // 타입 문자열 → NotificationType으로 변환
                        let type: NotificationType
                        switch typeString {
                        case "approval_pending":
                            type = .approval(status: .pending)
                        case "approval_approved":
                            type = .approval(status: .approved)
                        case "approval_rejected":
                            type = .approval(status: .rejected)
                        default:
                            type = .common // 기본값: 일반 알림
                        }

                        // 유효한 DummyNotification 객체로 생성
                        return DummyNotification(
                            isRead: isRead,
                            title: title,
                            content: body,
                            time: timeAgo,
                            type: type
                        )
                    } ?? []

                    // 변환된 알림 리스트를 observer에게 전달
                    observer.onNext(notifications)
                    observer.onCompleted()
                }

            // 옵저버가 dispose될 때 정리 작업 수행
            return Disposables.create()
        }
    }
}

extension DummyNotification {
    
    /// 주어진 날짜(Date)로부터 현재 시각까지 경과한 시간을 사람이 읽기 쉬운 문자열로 반환합니다.
    ///
    /// - Parameter date: 기준이 되는 과거 시각
    /// - Returns: "n초 전", "n분 전", "n시간 전", 또는 "n일 전" 형식의 문자열
    ///
    /// 이 함수는 알림 UI 등에 사용되어, 사용자가 알림이 얼마나 최근에 생성되었는지 직관적으로 파악할 수 있도록 도와줍니다.
    static func calculateTimeAgo(from date: Date) -> String {
        // 현재 시각과 전달받은 시각 간의 차이를 초 단위로 계산
        let secondsAgo = Int(Date().timeIntervalSince(date))
        
        // 60초 미만일 경우: "n초 전"
        if secondsAgo < 60 {
            return "\(secondsAgo)초 전"
        }
        // 1시간 미만일 경우: "n분 전"
        else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)분 전"
        }
        // 24시간 미만일 경우: "n시간 전"
        else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)시간 전"
        }
        // 1일 이상일 경우: "n일 전"
        else {
            return "\(secondsAgo / 86400)일 전"
        }
    }
}
