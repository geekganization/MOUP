//
//  CalendarEventListViewController.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import UIKit

import Then

final class CalendarEventListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CalendarEventListVCDelegate?
    
    private let day: Int
    
    // MARK: - UI Components
    
    private let calendarEventListView = CalendarEventListView()
    
    // MARK: - Initializer
    
    init(day: Int) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarEventListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.viewWillDisappear()
    }
}

// MARK: - UI Methods

private extension CalendarEventListViewController {
    func configure() {
        setStyles()
        setDelegates()
        setBinding()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
        
        calendarEventListView.getTitleLabel.text = "\(day)일"
    }
    
    func setDelegates() {
        calendarEventListView.getEventTableView.dataSource = self
        calendarEventListView.getEventTableView.delegate = self
    }
    
    func setBinding() {
//        calendarEventListView.getEventTableView
    }
}

// MARK: - 테스트용 DataSource, Delegate

extension CalendarEventListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.identifier, for: indexPath) as? EventCell else { return UITableViewCell() }
        
        return cell
    }
}

extension CalendarEventListViewController: UITableViewDelegate {
    
}
