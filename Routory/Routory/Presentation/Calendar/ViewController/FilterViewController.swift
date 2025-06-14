//
//  FilterViewController.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import UIKit

final class FilterViewController: UIViewController {
    
    // MARK: UI Components
    
    private let filterView = FilterView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = filterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterView.getWorkplaceTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
}

// MARK: - UI Methods

private extension FilterViewController {
    func configure() {
        setStyles()
        setDelegates()
        setActions()
        setBinding()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    func setDelegates() {
        filterView.getWorkplaceTableView.dataSource = self
        filterView.getWorkplaceTableView.delegate = self
    }
    
    func setActions() {
        filterView.getApplyButton.addAction(UIAction(handler: { _ in
            // TODO: 선택된 근무지/매장 전달
            self.dismiss(animated: true)
        }), for: .touchUpInside)
    }
    
    func setBinding() {
        
    }
}

// MARK: - 테스트용 DataSource, Delegate

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkplaceCell.identifier, for: indexPath) as? WorkplaceCell else { return UITableViewCell() }
        
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: WorkplaceTableHeaderView.identifier) as? WorkplaceTableHeaderView else { return UIView() }
        
        return header
    }
}
