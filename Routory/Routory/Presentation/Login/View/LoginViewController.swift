//
//  LoginViewController.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {

    // MARK: - View / ViewModel

    private let loginView = LoginView()
    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    // MARK: - Binding

    private func bindViewModel() {
        let input = LoginViewModel.Input(
            googleLoginTapped: loginView.kakaoLoginButton.rx.tap.asObservable(),
            presentingVC: self
        )

        let output = viewModel.transform(input: input)

        output.navigation
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] navigation in
                switch navigation {
                case .goToMain:
                    print("로그인 성공 - 메인 화면 이동")
                    // TODO: Coordinator를 통해 메인으로 이동

                case .goToSignup:
                    print("신규 사용자 - 회원가입 화면 이동")
                    // TODO: Coordinator를 통해 회원가입 화면 이동
                }
            })
            .disposed(by: disposeBag)
    }
}
