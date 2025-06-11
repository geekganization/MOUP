//
//  CalendarViewController.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

import JTAppleCalendar
import RxSwift
import SnapKit
import Then

final class CalendarViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let calendarView = CalendarView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - UI Methods

private extension CalendarViewController {
    func configure() {
        setStyles()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
        
        self.navigationController?.navigationBar.topItem?.title = "캘린더"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.headBold(20), .foregroundColor: UIColor.gray900]
        
        let todayButtonAction = UIAction(handler: { [weak self] _ in
            guard let self else { return }
            self.calendarView.getJTACalendar.scrollToDate(.now, animateScroll: true)
        })
        let todayButton = UIBarButtonItem(title: "오늘", primaryAction: todayButtonAction)
        todayButton.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .normal)
        self.navigationItem.rightBarButtonItem = todayButton
    }
}
