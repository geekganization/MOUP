//
//  InfoViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/10/25.
//

import UIKit

enum InfoMenu: CaseIterable {
    case termsOfService
    case privacyPolicy
    case openSourceLicense
//    case reviewAndRating
    
    var title: String {
        switch self {
        case .termsOfService: return "이용약관"
        case .privacyPolicy: return "개인정보처리방침"
        case .openSourceLicense: return "오픈소스 라이센스"
//        case .reviewAndRating: return "리뷰 및 별점주기"
        }
    }
}

final class InfoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let menuItems = InfoMenu.allCases
    
    // MARK: - UI Components
    
    private let infoView = InfoView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = infoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setTableView()
    }
    
    private func setTableView() {
        infoView.menuListView.menuTableView.delegate = self
        infoView.menuListView.menuTableView.dataSource = self
        infoView.menuListView.menuTableView.register(
            MyPageTableViewCell.self,
            forCellReuseIdentifier: MyPageTableViewCell.id
        )
        infoView.menuListView.menuTableView.separatorStyle = .none
    }
}

private extension InfoViewController {
    func configure() {
        setStyles()
        setActions()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Actions
    func setActions() {
        infoView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}

extension InfoViewController: UITableViewDelegate, UITableViewDataSource {
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
        tableView.deselectRow(at: indexPath, animated: true)
        let menu = menuItems[indexPath.row]
        
        switch menu {
//        case .reviewAndRating:
//            openAppStoreReviewPage()
        case .termsOfService:
            let termsOfServiceVC = PolicyViewController(fileName: "service_terms", title: "이용약관")
            navigationController?.pushViewController(termsOfServiceVC, animated: true)
        case .privacyPolicy:
            let termsOfServiceVC = PolicyViewController(fileName: "privacy_policy", title: "개인정보처리방침")
            navigationController?.pushViewController(termsOfServiceVC, animated: true)
        case .openSourceLicense:
            let opensourceLicenseVC = OpenSourceViewController()
            navigationController?.pushViewController(opensourceLicenseVC, animated: true)
        }
    }
    
    func openAppStoreReviewPage() {
        // TODO: 리뷰 및 별점주기
    }
}
