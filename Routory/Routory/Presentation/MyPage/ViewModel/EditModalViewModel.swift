//
//  EditModalViewModel.swift
//  Routory
//
//  Created by shinyoungkim on 6/12/25.
//

import RxSwift
import RxCocoa

final class EditModalViewModel {
    
    // MARK: - Input
    
    struct Input {
        let textChanged: Observable<String>
        let saveButtonDidTap: Observable<Void>
    }
    
    // MARK: - Output
    
    struct Output {
//        let saveCompleted: Observable<String>
        let validationError: Observable<String>
    }
    
    // MARK: - Properties
    
    private let userUseCase: UserUseCaseProtocol
    private let disposeBag = DisposeBag()
    private let validationErrorSubject = PublishSubject<String>()
    private let latestNickname = BehaviorRelay<String>(value: "")
    
    // MARK: - Initializer
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.textChanged
            .do(onNext: { [weak self] text in
                self?.latestNickname.accept(text)
                
                if let errorMessage = self?.validateNickname(text) {
                    self?.validationErrorSubject.onNext(errorMessage)
                } else {
                    self?.validationErrorSubject.onNext("")
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        // 추후 usecase 완성되면 연결
//        input.saveButtonDidTap
//            .withLatestFrom(latestNickname.asObservable())
//            .flatMapLatest { [weak self] nickname -> Observable<String> in
//                guard let self = self else { return .empty() }
//        
//                if let errorMessage = self.validateNickname(nickname) {
//                    self.validationErrorSubject.onNext(errorMessage)
//                    return .empty()
//                }
//
//                return self.userUseCase.updateUser(nickname)
//                    .andThen(Observable.just(nickname))
//                    .do(onNext: { [weak self] newNickname in
//                        self?.saveCompletedSubject.onNext(newNickname)
//                    })
//                    .catch { error in
//                        print("닉네임 저장 실패: \(error)")
//                    }
//            }
//            .subscribe()
//            .disposed(by: disposeBag)
        
        return Output(
//            saveCompleted: saveCompletedSubject.asObservable(),
            validationError: validationErrorSubject.asObservable()
        )
    }
    
    // MARK: - 유효성 검사
    
    private func validateNickname(_ nickname: String) -> String? {
        if nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "특수문자 제외 8자 이하로 입력해주세요"
        }
        if nickname.count > 8 {
            return "특수문자 제외 8자 이하로 입력해주세요"
        }
        let pattern = "[^가-힣a-zA-Z0-9]"
        if let _ = nickname.range(of: pattern, options: .regularExpression) {
            return "특수문자 제외 8자 이하로 입력해주세요"
        }
        
        return nil
    }
}
