//
//  SignupViewController.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit
import RxSwift

class SignupViewController: UIViewController {

    // MARK: - View / ViewModel
    private let signUpView = SignupView()
    private let signupViewModel: SignupViewModel
    private let disposeBag = DisposeBag()
    
    // Rx Input Subjects
    private let roleSelectedSubject = PublishSubject<String>()
    private let confirmTappedSubject = PublishSubject<Void>()

    // MARK: - Init
    init(signupViewModel: SignupViewModel) {
        self.signupViewModel = signupViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func loadView() {
        self.view = signUpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 역할 선택/확정 이벤트 바인딩
        signUpView.onRoleConfirmed = { [weak self] role in
            self?.roleSelectedSubject.onNext(role == "사장님" ? "owner" : "worker")
            self?.confirmTappedSubject.onNext(())
        }

        // ViewModel Input/Output 바인딩
        let input = SignupViewModel.Input(
            roleSelected: roleSelectedSubject.asObservable(),
            confirmTapped: confirmTappedSubject.asObservable()
        )
        let output = signupViewModel.transform(input: input)
        
        output.signupSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("회원가입 성공!")
                // TODO: Coordinator를 통해 메인화면으로 이동
            })
            .disposed(by: disposeBag)
        
        output.signupError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("회원가입 실패: \(error)")
                // TODO: 에러 메세지
            })
            .disposed(by: disposeBag)
    }
}
