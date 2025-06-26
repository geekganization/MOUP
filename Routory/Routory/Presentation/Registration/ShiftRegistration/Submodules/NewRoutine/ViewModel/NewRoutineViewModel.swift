//
//  NewRoutineViewModel.swift
//  Routory
//
//  Created by tlswo on 6/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class NewRoutineViewModel {

    enum Mode {
        case create
        case edit(routineId: String)
        case read
    }

    struct Input {
        let saveTrigger: Observable<Routine>
    }

    struct Output {
        let didSaveRoutine: Observable<Void>
        let errorMessage: Observable<String>
    }

    private let useCase: RoutineUseCaseProtocol
    private let uid: String
    private let mode: Mode
    private let disposeBag = DisposeBag()

    private let didSaveRoutineRelay = PublishRelay<Void>()
    private let errorMessageRelay = PublishRelay<String>()

    init(useCase: RoutineUseCaseProtocol, uid: String, mode: Mode) {
        self.useCase = useCase
        self.uid = uid
        self.mode = mode
    }

    func transform(input: Input) -> Output {
        input.saveTrigger
            .flatMapLatest { [weak self] routine -> Observable<Event<Void>> in
                guard let self = self else { return .empty() }

                let action: Observable<Void>
                switch self.mode {
                case .create:
                    action = self.useCase.createRoutine(uid: self.uid, routine: routine)
                case .edit(let routineId):
                    action = self.useCase.updateRoutine(uid: self.uid, routineId: routineId, routine: routine)
                case .read:
                    action = self.useCase.createRoutine(uid: self.uid, routine: routine)
                    break
                }

                return action.materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    self?.didSaveRoutineRelay.accept(())
                case .error(let error):
                    self?.errorMessageRelay.accept("루틴 저장 실패: \(error.localizedDescription)")
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)

        return Output(
            didSaveRoutine: didSaveRoutineRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
}
