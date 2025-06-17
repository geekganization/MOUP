//
//  CalendarService.swift
//  Routory
//
//  Created by 양원식 on 6/17/25.
//

import RxSwift
import FirebaseFirestore

protocol CalendarServiceProtocol {
    func addUserToCalendarSharedWith(calendarId: String, uid: String) -> Observable<Void>
}

final class CalendarService: CalendarServiceProtocol {
    private let db = Firestore.firestore()
    
    /// 캘린더의 sharedWith 배열에 사용자의 uid를 추가합니다.
    ///
    /// - Parameters:
    ///   - calendarId: 공유할 캘린더의 Firestore documentID
    ///   - uid: 공유에 추가할 사용자 UID
    /// - Returns: 성공 시 완료(Void)를 방출하는 Observable
    /// - Firestore 경로: calendars/{calendarId}/sharedWith (arrayUnion)
    func addUserToCalendarSharedWith(calendarId: String, uid: String) -> Observable<Void> {
        let calendarRef = db.collection("calendars").document(calendarId)
        return Observable.create { observer in
            calendarRef.updateData([
                "sharedWith": FieldValue.arrayUnion([uid])
            ]) { error in
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
