//
//  MyPageViewController.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit
import RxSwift
import SnapKit
import Then
import FirebaseAuth

enum MyPageMenu: CaseIterable {
    case account
    case notification
    case contact
    case info
    
    var title: String {
        switch self {
        case .account: return "계정"
        case .notification: return "알림 설정"
        case .contact: return "문의하기"
        case .info: return "정보"
        }
    }
}

final class MyPageViewController: UIViewController {
    
    // MARK: - Properties
    
    private let uid: String
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    private let uidSubject = BehaviorSubject<String>(value: "")
    
    private let menuItems = MyPageMenu.allCases
    
    // MARK: - UI Components
    
    private let myPageView = MyPageView()
    
    // MARK: - Initializer
    
    init(viewModel: MyPageViewModel, uid: String) {
        self.viewModel = viewModel
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    @objc private func logoutButtonDidTap() {
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

private extension MyPageViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setTableView()
        setActions()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - setTableView
    func setTableView() {
        myPageView.menuListView.menuTableView.delegate = self
        myPageView.menuListView.menuTableView.dataSource = self
        myPageView.menuListView.menuTableView.register(
            MyPageTableViewCell.self,
            forCellReuseIdentifier: MyPageTableViewCell.id
        )
        myPageView.menuListView.menuTableView.separatorStyle = .none
    }
    
    // MARK: - setActions
    func setActions() {
        myPageView.logoutButtonView.addTarget(
            self,
            action: #selector(logoutButtonDidTap),
            for: .touchUpInside
        )
        
        myPageView.onEditButtonTapped = { [weak self] in
            let userUseCase = UserUseCase(userRepository: UserRepository(userService: UserService()))
            let editModelVC = EditModalViewController(viewModel: EditModalViewModel(userUseCase: userUseCase))
            editModelVC.modalPresentationStyle = .overFullScreen
            editModelVC.modalTransitionStyle = .crossDissolve
            self?.present(editModelVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        let input = MyPageViewModel.Input(uid: Observable.just(uid))
        let output = viewModel.transform(input: input)
        
        output.user
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.myPageView.update(user: user)
            })
            .disposed(by: disposeBag)
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyPageTableViewCell.id,
            for: indexPath
        ) as? MyPageTableViewCell else {
            return UITableViewCell()
        }
        
        cell.title = menuItems[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMenu = menuItems[indexPath.row]
        
        switch selectedMenu {
        case .account:
            let accountVC = AccountViewController()
            navigationController?.pushViewController(accountVC, animated: true)
        case .notification:
            print("알림 설정 메뉴 클릭")
        case .contact:
            print("문의하기 메뉴 클릭")
        case .info:
            let infoVC = InfoViewController()
            navigationController?.pushViewController(infoVC, animated: true)
        }
    }
}
