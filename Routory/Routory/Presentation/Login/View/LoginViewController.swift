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

    // MARK: - Properties

    private let viewModel: LoginViewModel
    private let loginView = LoginView()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init(viewModel:) instead")
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - Private Methods

private extension LoginViewController {
    func configure() {
        setBinding()
        setStyles()
    }

    func setBinding() {
        let input = LoginViewModel.Input(
            appleLoginTapped: loginView.getAppleLoginButton.rx.tap.asObservable(),
            googleLoginTapped: loginView.getGoogleLoginButton.rx.tap.asObservable(),
            presentingVC: self
        )
        
        let output = viewModel.transform(input: input)
        
        output.navigation
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] navigation in
                switch navigation {
                case .goToMain:
                    print("로그인 성공 - 메인 화면 이동")
                    let tabBarVM = TabBarViewModel()
                    let tabBarVC = TabBarViewController(viewModel: tabBarVM)
                    
                    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let sceneDelegate = scene.delegate as? SceneDelegate,
                          let window = sceneDelegate.window else { return }
                    
                    window.rootViewController = tabBarVC
                    window.makeKeyAndVisible()
                case .goToSignup(let nickname, let credential):
                    print("신규 사용자 - 회원가입 화면 이동")
                    // DI
                    let userService = UserService()
                    let userRepository = UserRepository(userService: userService)
                    let userUseCase = UserUseCase(userRepository: userRepository)
                    let signupViewModel = SignupViewModel(
                        userUseCase: userUseCase,
                        credential: credential,
                        userName: nickname
                    )
                    let signupVC = SignupViewController(signupViewModel: signupViewModel)
                    self?.navigationController?.pushViewController(signupVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
}
