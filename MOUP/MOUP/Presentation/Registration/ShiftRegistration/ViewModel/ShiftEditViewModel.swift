//
//  ShiftEditViewModel.swift
//  Routory
//
//  Created by tlswo on 6/26/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ShiftEditViewModel {

    struct Input {
        let submitTrigger: Observable<(String, String, CalendarEvent)>
        // (workplaceId, eventId, event)
    }

    struct Output {
        let submissionResult: Observable<Result<Void, Error>>
    }

    private let calendarUseCase: CalendarUseCase
    private let disposeBag = DisposeBag()

    init(calendarUseCase: CalendarUseCase) {
        self.calendarUseCase = calendarUseCase
    }

    func transform(input: Input) -> Output {
        let result = input.submitTrigger
            .flatMapLatest { [weak self] workplaceId, eventId, event -> Observable<Result<Void, Error>> in
                guard let self else {
                    return Observable.just(.failure(NSError(domain: "Deallocated", code: -1)))
                }

                return self.calendarUseCase.fetchCalendarIdByWorkplaceId(workplaceId: workplaceId)
                    .flatMap { calendarId -> Observable<Result<Void, Error>> in
                        guard let calendarId else {
                            return Observable.just(.failure(NSError(domain: "CalendarNotFound", code: 0)))
                        }

                        return self.calendarUseCase.updateEventInCalendar(calendarId: calendarId, eventId: eventId, event: event)
                            .map { .success(()) }
                            .catch { error in
                                Observable.just(.failure(error))
                            }
                    }
            }
            .observe(on: MainScheduler.instance)

        return Output(submissionResult: result)
    }
}
