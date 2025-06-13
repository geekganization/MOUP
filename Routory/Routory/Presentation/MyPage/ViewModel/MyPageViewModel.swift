//
//  MyPageViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import RxSwift

/// 마이페이지 화면에 필요한 유저 정보를 제공하는 ViewModel.
/// - Input: 현재 로그인한 유저의 uid.
/// - Output: uid에 해당하는 User 정보를 Observable로 제공.
final class MyPageViewModel {
    
    // MARK: - Input
    
    /// View에서 주입받는 Input 구조체.
    /// 현재 로그인한 유저의 uid 스트림.
    struct Input {
        let uid: Observable<String>
    }
    
    // MARK: - Output
    
    /// ViewModel에서 View로 제공하는 Output 구조체.
    /// 유저 정보(User)를 Observable로 제공.
    struct Output {
        let user: Observable<User>
    }
    
    // MARK: - Private
    
    /// 유저 정보를 가져오는 유즈케이스
    private let userUseCase: UserUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    /// ViewModel 생성자
    /// - Parameter userUseCase: User 정보를 가져오기 위한 유즈케이스 객체
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    // MARK: - Transform
    
    /// Input을 기반으로 Output을 생성하는 메서드
    /// - Parameter input: View에서 전달받은 Input
    /// - Returns: Output 구조체 (user Observable 포함)
    func transform(input: Input) -> Output {
        /// uid Observable을 기반으로 유저 정보 Observable을 생성
        let user = input.uid
            .flatMapLatest { [weak self] uid -> Observable<User> in
                guard let self = self else { return .empty() }
                // 유저 정보를 가져오는 유즈케이스 실행
                return self.userUseCase.fetchUser(uid: uid)
            }
        // 최신 값을 유지하고 View에서 구독 시 즉시 최신 값을 전달하도록 설정
            .share(replay: 1, scope: .whileConnected)
        
        return Output(user: user)
    }
}
