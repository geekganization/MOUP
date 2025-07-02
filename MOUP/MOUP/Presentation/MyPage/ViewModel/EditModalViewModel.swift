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
        let saveCompleted: Observable<String>
        let validationError: Observable<String>
    }
    
    // MARK: - Properties
    
    private let userUseCase: UserUseCaseProtocol
    private let disposeBag = DisposeBag()
    private let validationErrorSubject = PublishSubject<String>()
    private let saveCompletedSubject = PublishSubject<String>()
    private let latestNickname = BehaviorRelay<String>(value: "")
    private let uid: String
    
    // MARK: - Initializer

    init(uid: String, userUseCase: UserUseCaseProtocol) {
        self.uid = uid
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
        
        input.saveButtonDidTap
            .withLatestFrom(latestNickname.asObservable())
            .flatMapLatest { [weak self] nickname -> Observable<String> in
                guard let self = self else { return .empty() }
        
                if let errorMessage = self.validateNickname(nickname) {
                    self.validationErrorSubject.onNext(errorMessage)
                    return .empty()
                }

                return self.userUseCase.updateUserName(uid: uid, newUserName: nickname)
                    .map { _ in nickname }
                    .do(onNext: { [weak self] newNickname in
                        self?.saveCompletedSubject.onNext(newNickname)
                    })
                    .catch { [weak self] error in
                        self?.validationErrorSubject.onNext("닉네임 저장 실패.")
                        return .empty()
                    }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        return Output(
            saveCompleted: saveCompletedSubject.asObservable(),
            validationError: validationErrorSubject.asObservable()
        )
    }
    
    // MARK: - 유효성 검사
    
    private func validateNickname(_ nickname: String) -> String? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "한글, 영문 또는 숫자만 사용하여 8자 이하로 입력해주세요"
        }

        if nickname.contains(where: { $0.isWhitespace }) {
            return "공백은 사용할 수 없어요"
        }

        if trimmed.range(of: "^[ㄱ-ㅎ]+$", options: .regularExpression) != nil {
            return "자음만 사용할 수 없어요"
        }

        if trimmed.range(of: "^[ㅏ-ㅣ]+$", options: .regularExpression) != nil {
            return "모음만 사용할 수 없어요"
        }

        if trimmed.range(of: "[ㄱ-ㅎㅏ-ㅣ]", options: .regularExpression) != nil {
            return "정확한 글자를 입력해주세요"
        }

        let containsHangul = trimmed.range(of: "[가-힣]", options: .regularExpression) != nil
        let containsAlphabet = trimmed.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        if containsHangul && containsAlphabet {
            return "한글 또는 영문만 사용할 수 있어요"
        }

        if trimmed.range(of: "[^가-힣a-zA-Z0-9]", options: .regularExpression) != nil {
            return "특수문자는 사용할 수 없어요"
        }

        if trimmed.count > 8 {
            return "8자 이하로 입력해주세요"
        }

        return nil
    }
}
