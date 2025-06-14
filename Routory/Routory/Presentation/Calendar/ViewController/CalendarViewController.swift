//
//  CalendarViewController.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

import JTAppleCalendar
import RxCocoa
import RxSwift
import Then

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel()
    
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
        setDelegates()
        setActions()
        setBinding()
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
        todayButton.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .selected)
        self.navigationItem.rightBarButtonItem = todayButton
    }
    
    func setDelegates() {
        calendarView.delegate = self
    }
    
    func setActions() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didYearMonthLabelTapped(_:)))
        calendarView.getCalendarHeaderView.getYearMonthLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setBinding() {
        let input = CalendarViewModel.Input(viewDidLoad: Infallible.just(()))
        
        let output = viewModel.tranform(input: input)
    }
}

// MARK: - @objc Methods

@objc private extension CalendarViewController {
    func didYearMonthLabelTapped(_ sender: UITapGestureRecognizer) {
        guard let yearMonthText = calendarView.getCalendarHeaderView.getYearMonthLabel.text,
              let currYear = Int(yearMonthText.prefix(4)),
              let currMonth = Int(yearMonthText.suffix(2)) else { return }
        
        let pickerModalVC = YearMonthPickerViewController(currYear: currYear, currMonth: currMonth)
        pickerModalVC.delegate = self
        
        if let sheet = pickerModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
        }
        
        self.present(pickerModalVC, animated: true)
    }
}

// MARK: - CalendarViewDelegate

extension CalendarViewController: CalendarViewDelegate {
    func didSelectCell(day: Int, eventList: [CalendarEvent]) {
        let viewModel = CalendarEventListViewModel(eventList: eventList)
        let calendarEventListModalVC = CalendarEventListViewController(viewModel: viewModel, day: day)
        
        let modalNC = UINavigationController(rootViewController: calendarEventListModalVC)
        if let sheet = modalNC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        self.present(modalNC, animated: true)
    }
}

// MARK: - YearMonthPickerVCDelegate

extension CalendarViewController: YearMonthPickerVCDelegate {
    func gotoButtonDidTapped(year: Int, month: Int) {
        let yearMonthText = "\(year). \(month)"
        guard let date = calendarView.getDateFormatter.date(from: yearMonthText) else { return }
        calendarView.getJTACalendar.scrollToDate(date)
    }
}
