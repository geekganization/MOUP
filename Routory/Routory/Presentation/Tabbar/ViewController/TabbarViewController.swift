//
//  TabbarViewController.swift
//  Routory
//
//  Created by 서동환 on 6/9/25.
//

import UIKit

final class TabbarViewController: UITabBarController {
    
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
        let homeVC = HomeViewController()
        let calendarVC = CalendarViewController()
        let myPageVC = MyPageViewController()
        
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: .homeUnselected, selectedImage: .homeSelected.withRenderingMode(.alwaysOriginal))
        calendarVC.tabBarItem = UITabBarItem(title: "캘린더", image: .calendarUnselected, selectedImage: .calendarSelected.withRenderingMode(.alwaysOriginal))
        myPageVC.tabBarItem = UITabBarItem(title: "마이페이지", image: .myPageUnselected, selectedImage: .myPageSelected.withRenderingMode(.alwaysOriginal))
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let calendarNav = UINavigationController(rootViewController: calendarVC)
        let myPageNav = UINavigationController(rootViewController: myPageVC)
        
        self.setViewControllers([homeNav, calendarNav, myPageNav], animated: false)
    }
}
