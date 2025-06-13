//
//  AccountViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/11/25.
//

import UIKit
import FirebaseAuth

final class AccountViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let accountView = AccountView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = accountView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension AccountViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setActions()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - setActions
    func setActions() {
        accountView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButonDidTap),
            for: .touchUpInside
        )
        
        accountView.onDeleteAccountTapped = { [weak self] in
            guard let self else { return }

            // 현재 로그인한 유저의 uid 가져오기
            guard let userId = Auth.auth().currentUser?.uid else {
                print("유저 ID를 찾을 수 없습니다.")
                return
            }

            let userUseCase = UserUseCase(userRepository: UserRepository(userService: UserService()))
            let authUseCase = AuthUseCase(authRepository: AuthRepository(authService: AuthService()))
            let deleteAccountViewModel = DeleteAccountViewModel(
                userUseCase: userUseCase, authUseCase: authUseCase,
                userId: userId
            )
            let deleteModalVC = DeleteAccountModalViewController(viewModel: deleteAccountViewModel)
            deleteModalVC.modalPresentationStyle = .overFullScreen
            deleteModalVC.modalTransitionStyle = .crossDissolve
            self.present(deleteModalVC, animated: true, completion: nil)
        }
    }
    
    @objc func backButonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}
