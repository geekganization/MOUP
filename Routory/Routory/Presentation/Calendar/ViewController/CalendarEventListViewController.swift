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
    
    private let viewModel: CalendarEventListViewModel
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.textColor = .gray900
    }
    
    private let calendarEventListView = CalendarEventListView()
    
    // MARK: - Initializer
    
    init(viewModel: CalendarEventListViewModel, day: Int) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = "\(day)일"
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
    }
    
    func setStyles() {
//        self.view.backgroundColor = .primaryBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
}
