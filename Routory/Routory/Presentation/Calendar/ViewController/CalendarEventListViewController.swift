//
//  CalendarEventListViewController.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class CalendarEventListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CalendarEventListVCDelegate?
    
    private let disposeBag = DisposeBag()
    
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
    }
    
    func setBinding() {
        calendarEventListView.getEventTableView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                // TODO: 사장님 근무 VC에 데이터 연결
                owner.delegate?.didTapEventCell()
            }.disposed(by: disposeBag)
        
        calendarEventListView.getAssignButton.rx.tap
            .subscribe(with: self) { owner, _ in
                // TODO: 사장님 근무 VC에 데이터 연결
                owner.delegate?.didTapAssignButton()
            }.disposed(by: disposeBag)
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
