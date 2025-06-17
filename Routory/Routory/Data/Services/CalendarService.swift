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
