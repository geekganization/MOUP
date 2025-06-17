//
//  SignupViewController.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit
import RxSwift

final class SignupViewController: UIViewController {

    // MARK: - Properties

    private let signupViewModel: SignupViewModel
    private let signUpView = SignupView()
    private let disposeBag = DisposeBag()
    
    // Rx Input Subjects
    private let roleSelectedSubject = PublishSubject<String>()
    private let confirmTappedSubject = PublishSubject<Void>()

    // MARK: - Init

    init(signupViewModel: SignupViewModel) {
        self.signupViewModel = signupViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init(signupViewModel:) instead")
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = signUpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - Private Methods

private extension SignupViewController {
    func configure() {
        setBinding()
    }

    func setBinding() {
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
                let tabbarVC = TabbarViewController(viewModel: TabBarViewModel())
                
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = scene.delegate as? SceneDelegate,
                      let window = sceneDelegate.window else { return }
                
                window.rootViewController = tabbarVC
                window.makeKeyAndVisible()
            })
            .disposed(by: disposeBag)
        
        output.signupError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("회원가입 실패: \(error)")
                // TODO: 에러 메시지 노출
            })
            .disposed(by: disposeBag)
    }
}
