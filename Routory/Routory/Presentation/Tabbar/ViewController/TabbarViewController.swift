//
//  TabbarViewController.swift
//  Routory
//
//  Created by 서동환 on 6/9/25.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseAuth

final class TabbarViewController: UITabBarController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let viewModel: TabBarViewModel
    private let input: TabBarViewModel.Input
    private let output: TabBarViewModel.Output
    private lazy var myPageVM = MyPageViewModel(userObservable: output.user)

    // MARK: - Initializer
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        self.input = TabBarViewModel.Input(viewDidLoad: viewDidLoadRelay.asObservable())
        self.output = viewModel.tranform(input: input)
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

// MARK: - UI Methods

private extension TabbarViewController {
    func configure() {
        setStyles()
        setTabBarItems()
        setBindings()
    }
    
    func setStyles() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont.bodyMedium(12)]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = fontAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = fontAttributes
        
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    func setTabBarItems() {
        let homeVC = HomeViewController(homeViewModel: HomeViewModel(userUseCase: UserUseCase(userRepository: UserRepository(userService: UserService()))))
        let calendarVC = CalendarViewController()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("유저 ID를 찾을 수 없습니다.")
            return
        }
        let myPageVC = MyPageViewController(viewModel: myPageVM, uid: userId)
        
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: .homeUnselected, selectedImage: .homeSelected.withRenderingMode(.alwaysOriginal))
        calendarVC.tabBarItem = UITabBarItem(title: "캘린더", image: .calendarUnselected, selectedImage: .calendarSelected.withRenderingMode(.alwaysOriginal))
        myPageVC.tabBarItem = UITabBarItem(title: "마이페이지", image: .myPageUnselected, selectedImage: .myPageSelected.withRenderingMode(.alwaysOriginal))
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let calendarNav = UINavigationController(rootViewController: calendarVC)
        let myPageNav = UINavigationController(rootViewController: myPageVC)
        
        self.setViewControllers([homeNav, calendarNav, myPageNav], animated: false)
    }

    func setBindings() {
        output.user
            .subscribe(onNext: { user in
                print("유저 데이터 받음: \(user)")
            })
            .disposed(by: disposeBag)

        viewDidLoadRelay.accept(())
    }
}
