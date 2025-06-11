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
    case reviewAndRating
    
    var title: String {
        switch self {
        case .termsOfService: return "이용약관"
        case .privacyPolicy: return "개인정보처리방침"
        case .openSourceLicense: return "오픈소스 라이센스"
        case .reviewAndRating: return "리뷰 및 별점주기"
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
        infoView.menuList.tableView.delegate = self
        infoView.menuList.tableView.dataSource = self
        infoView.menuList.tableView.register(
            MyPageTableViewCell.self,
            forCellReuseIdentifier: MyPageTableViewCell.id
        )
        infoView.menuList.tableView.separatorStyle = .none
    }
}

extension InfoViewController {
    private func configure() {
        setStyles()
        setActions()
    }
    
    // MARK: - setStyles
    private func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Actions
    private func setActions() {
        infoView.navigationBar.backButton.addTarget(
            self,
            action: #selector(backButonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc private func backButonDidTap() {
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
        
        cell.titleLabel.text = menuItems[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
