//
//  DeleteAccountModalViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/11/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import FirebaseAuth

final class DeleteAccountModalViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let deleteAccountModal = DeleteAccountModal().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Dependencies
    private let viewModel: DeleteAccountViewModel
    private let disposeBag = DisposeBag()
    
    private let confirmTappedSubject = PublishSubject<Void>()
    
    // MARK: - Init
    init(viewModel: DeleteAccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "Use init(viewModel:) instead")
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:) instead")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension DeleteAccountModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubview(deleteAccountModal)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .background
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        deleteAccountModal.snp.makeConstraints {
            $0.height.equalTo(348)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - setActions
    func setActions() {
        deleteAccountModal.onRequestDismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        deleteAccountModal.onRequestDeleteAccount = { [weak self] in
            self?.confirmTappedSubject.onNext(())
        }
    }
    
    func setBinding() {
        let input = DeleteAccountViewModel.Input(
            confirmDeleteTapped: confirmTappedSubject.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.deleteCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("탈퇴 완료")
                self?.logoutAndGoToLoginScreen()
            })
            .disposed(by: disposeBag)
        
        output.errorOccurred
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("탈퇴 실패: \(error)")
            })
            .disposed(by: disposeBag)
        
    }
    
    func logoutAndGoToLoginScreen() {
        do {
            try Auth.auth().signOut()
            
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = scene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else {
                return
            }
            
            let loginVC = LoginViewController(
                viewModel: LoginViewModel(
                    googleAuthService: GoogleAuthService(),
                    userService: UserService()
                )
            )
            let navController = UINavigationController(rootViewController: loginVC)
            
            guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
                window.rootViewController = navController
                return
            }
            
            navController.view.frame = window.bounds
            navController.view.transform = CGAffineTransform(translationX: -window.bounds.width * 0.3, y: 0)
            window.addSubview(navController.view)
            window.addSubview(snapshot)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                snapshot.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
                navController.view.transform = .identity
            }, completion: { _ in
                snapshot.removeFromSuperview()
                window.rootViewController = navController
                window.makeKeyAndVisible()
            })
        } catch {
            print("로그아웃 실패: \(error)")
        }
    }
}
