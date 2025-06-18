//
//  InviteCodeViewModel.swift
//  Routory
//
//  Created by shinyoungkim on 6/18/25.
//

import Foundation
import RxSwift

final class InviteCodeViewModel {
    // MARK: - Input
    /// ViewModel로 전달되는 사용자 입력 또는 이벤트 스트림 정의
    struct Input {
        /// 사용자가 텍스트 필드에 입력한 초대 코드 스트림
        let inviteCode: Observable<String>
        
        /// "조회하기" 버튼이 눌렸을 때의 트리거 이벤트 스트림
        let searchTrigger: Observable<Void>
    }

    // MARK: - Output
    /// ViewModel이 외부로 방출하는 처리 결과 스트림 정의
    struct Output {
        /// 초대코드를 통해 조회된 근무지 정보 스트림
        let workplace: Observable<WorkplaceInfo>
        
        /// 조회 실패 시 발생하는 에러 스트림
        let error: Observable<Error>
    }
    
    // MARK: - Properties

    /// 초대코드를 통해 근무지 정보를 조회하는 유즈케이스
    private let useCase: WorkplaceUseCaseProtocol
    
    // MARK: - Initializer

    /// 의존성 주입을 통해 유즈케이스를 설정하는 이니셜라이저입니다.
    /// - Parameter useCase: 초대코드 기반 근무지 조회를 담당하는 유즈케이스
    init(useCase: WorkplaceUseCaseProtocol) {
        self.useCase = useCase
    }
    
    // MARK: - Transform

    /// ViewController에서 전달받은 입력(Input)을 바탕으로 유즈케이스를 실행하고, 결과를 Output으로 방출합니다.
    /// - Parameter input: 사용자 입력 및 버튼 액션 등의 이벤트 스트림
    /// - Returns: 근무지 정보 또는 에러를 방출하는 Output 스트림
    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<Error>()

        let result = input.searchTrigger
            // 최신 초대코드 값과 함께 "조회하기" 트리거를 감지
            .withLatestFrom(input.inviteCode)
            // 초대코드로 서버에서 근무지 정보 조회
            .flatMapLatest { [weak self] code -> Observable<WorkplaceInfo> in
                guard let self = self else { return .empty() }

                return self.useCase.getWorkplaceInfoByInviteCode(inviteCode: code)
                    .flatMap { info -> Observable<WorkplaceInfo> in
                        if let info = info {
                            return .just(info)
                        } else {
                            // 수동으로 에러를 생성해 errorSubject로 방출
                            let error = NSError(
                                domain: "InviteCode",
                                code: 404,
                                userInfo: [NSLocalizedDescriptionKey: "해당 초대코드에 대한 근무지를 찾을 수 없습니다."]
                            )
                            errorSubject.onNext(error)
                            return .empty()
                        }
                    }
                    .catch { error in
                        errorSubject.onNext(error)
                        return .empty()
                    }
            }
            .share()

        return Output(
            workplace: result,
            error: errorSubject.asObservable()
        )
    }
}
