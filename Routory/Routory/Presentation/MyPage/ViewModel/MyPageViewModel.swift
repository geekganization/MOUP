//
//  MyPageViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import RxSwift

/// 마이페이지 화면에 필요한 유저 정보를 제공하는 ViewModel.
final class MyPageViewModel {
    
    // MARK: - Private
    let userObservable: Observable<User> // 읽기 전용 스트림이므로 internal하게 유지
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    /// ViewModel 생성자
    /// - Parameter userObservable: User 정보를 담은 스트림을 받아 그대로 전달
    init(userObservable: Observable<User>) {
        self.userObservable = userObservable
    }
}
