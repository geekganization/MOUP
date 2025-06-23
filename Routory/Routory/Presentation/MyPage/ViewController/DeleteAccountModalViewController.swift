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
    
    var deleteAccountContentModel: DeleteAccountModal { deleteAccountModal }
    
    // MARK: - Dependencies
    private let viewModel: DeleteAccountViewModel
    private let disposeBag = DisposeBag()
    
    private let confirmTappedSubject = PublishSubject<Void>()
    
    // MARK: - Init
    init(viewModel: DeleteAccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
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
        view.backgroundColor = .modalBackground
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
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundDidTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
            .subscribe(onNext: { [weak self] error in
                let nsError = error as NSError
                var errorMessage = ""

                if nsError.domain == "FIRAuthErrorDomain", nsError.code == 17014 {
                    errorMessage = "세션이 만료되어 탈퇴에 실패했습니다.\n로그아웃 로그인 후에 다시 시도해주세요."
                } else {
                    errorMessage = "일시적인 오류가 발생했습니다. 다시 시도해주세요."
                }
                
                let deleteAccountFailVC = DeleteAccountFailModalViewController()
                deleteAccountFailVC.update(errorMessage: errorMessage)
                deleteAccountFailVC.modalPresentationStyle = .overFullScreen
                deleteAccountFailVC.modalTransitionStyle = .crossDissolve
                self?.present(deleteAccountFailVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
    
    func logoutAndGoToLoginScreen() {
        print("로그아웃 및 화면전환 진입")
        do {
            try Auth.auth().signOut()
            
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = scene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else {
                return
            }
            
            let loginVC = LoginViewController(
                viewModel: LoginViewModel(
                    appleAuthService: AppleAuthService(),
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
    
    @objc func backgroundDidTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if deleteAccountModal.frame.contains(location) == false {
            dismiss(animated: true)
        }
    }
}
