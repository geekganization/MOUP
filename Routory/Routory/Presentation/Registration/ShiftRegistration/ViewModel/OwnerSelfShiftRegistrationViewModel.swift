//
//  OwnerSelfShiftRegistrationViewModel.swift
//  Routory
//
//  Created by tlswo on 6/18/25.
//

import Foundation
import RxSwift
import RxCocoa

final class OwnerSelfShiftRegistrationViewModel {

    struct Input {
        let submitTrigger: Observable<(String, CalendarEvent)>
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
            .flatMapLatest { [weak self] workplaceId, event -> Observable<Result<Void, Error>> in
                guard let self else {
                    return Observable.just(Result<Void, Error>.failure(NSError(domain: "", code: -1)))
                }

                return self.calendarUseCase.fetchCalendarIdByWorkplaceId(workplaceId: workplaceId)
                    .flatMap { calendarId -> Observable<Result<Void, Error>> in
                        guard let calendarId else {
                            return Observable.just(Result<Void, Error>.failure(NSError(domain: "CalendarNotFound", code: 0)))
                        }

                        return self.calendarUseCase.addEventToCalendar(calendarId: calendarId, event: event)
                            .map { Result<Void, Error>.success(()) }
                            .catch { error in
                                Observable.just(Result<Void, Error>.failure(error))
                            }
                    }
            }
            .observe(on: MainScheduler.instance)

        return Output(submissionResult: result)
    }
}
