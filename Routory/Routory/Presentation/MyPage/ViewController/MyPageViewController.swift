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

struct DummyUser {
    let name: String
    let role: String
}

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
    
    private let menuItems = MyPageMenu.allCases
    
    // MARK: - UI Components
    
    private let myPageView = MyPageView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setUser()
    }
    
    private func setUser() {
        let dummyUser = DummyUser(name: "김알바", role: "알바생")
        
        myPageView.update(user: dummyUser)
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
            
            window.rootViewController = UINavigationController(rootViewController: loginVC)
            window.makeKeyAndVisible()
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
            print("계정 메뉴 클릭")
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
