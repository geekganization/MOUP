//
//  WorkplaceListViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit

struct DummyWorkplace {
    let name: String
    let isSelected: Bool
}

final class WorkplaceListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var dummyWorkplace: [DummyWorkplace] = [
        DummyWorkplace(name: "GS25 이매역점", isSelected: false),
        DummyWorkplace(name: "이마트24 분당정자점", isSelected: false),
        DummyWorkplace(name: "CU 서현점", isSelected: true)
    ]
    
    // MARK: - UI Components
    
    private let workplaceListView = WorkplaceListView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = workplaceListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setTableView()
    }
    
    func setTableView() {
        let tableView = workplaceListView.workplaceTableView
        tableView.delegate = self
        tableView.dataSource = self
    }
}

private extension WorkplaceListViewController {
    // MARK: - configure
    func configure() {
        setActions()
    }
    
    // MARK: - setActions
    func setActions() {
        workplaceListView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}

extension WorkplaceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyWorkplace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WorkplaceListTableViewCell.id,
            for: indexPath
        ) as? WorkplaceListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.update(workplace: dummyWorkplace[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
