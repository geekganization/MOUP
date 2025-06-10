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

struct DummyUser {
    let name: String
    let role: String
}

final class MyPageViewController: UIViewController {
    
    // MARK: - Properties
    
    private let menuItems = ["계정", "알림 설정", "문의하기", "정보"]
    
    // MARK: - UI Components
    
    private let myPageView = MyPageView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
        
        setUser()
        setTableView()
    }
    
    private func setUser() {
        let dummyUser = DummyUser(name: "김알바", role: "알바생")
        
        myPageView.update(user: dummyUser)
    }
    
    private func setTableView() {
        myPageView.menuList.tableView.delegate = self
        myPageView.menuList.tableView.dataSource = self
        myPageView.menuList.tableView.register(
            MyPageTableViewCell.self,
            forCellReuseIdentifier: MyPageTableViewCell.id
        )
        myPageView.menuList.tableView.separatorStyle = .none
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
        
        cell.titleLabel.text = menuItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
