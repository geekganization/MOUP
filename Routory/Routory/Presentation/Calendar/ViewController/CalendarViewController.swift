//
//  CalendarViewController.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

import BetterSegmentedControl
import JTAppleCalendar
import RxCocoa
import RxSwift
import Then

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel()
    
    private let calendarMode = BehaviorRelay<CalendarMode>(value: .personal)
    
    /// `calendarView`에서 `dataSource` 관련 데이터의 연/월 형식을 만들기 위한 `DateFormatter`
    private let dataSourceDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy년 M월 d일"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    private var personalEventDataSource: [Date: [CalendarEvent]] = [:]
    private var sharedEventDataSource: [Date: [CalendarEvent]] = [:]
    
    // MARK: - UI Components
    
    private let calendarView = CalendarView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        populateDataSource()
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
        calendarView.getJTACalendar.calendarDataSource = self
        calendarView.getJTACalendar.calendarDelegate = self
    }
    
    func setActions() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didYearMonthLabelTapped(_:)))
        calendarView.getCalendarHeaderView.getYearMonthLabel.addGestureRecognizer(tapGestureRecognizer)
        
        calendarView.getCalendarHeaderView.getToggleSwitch.addAction(UIAction(handler: { [weak self] action in
            guard let self, let sender = action.sender as? BetterSegmentedControl else { return }
            calendarMode.accept(CalendarMode.allCases[sender.index])
        }), for: .valueChanged)
        
        calendarView.getCalendarHeaderView.getFilterButton.addAction(UIAction(handler: { [weak self] action in
            guard let self else { return }
            self.didFilterButtonTap()
        }), for: .touchUpInside)
    }
    
    func setBinding() {
//        let input = CalendarViewModel.Input(viewDidLoad: Infallible.just(()),
//                                            calendarMode: calendarMode)
        
//        let output = viewModel.tranform(input: input)
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

// MARK: - CalendarView Methods

private extension CalendarViewController {
    /// `jtaCalendar`의 셀을 탭했을 때 호출하는 메서드
    ///
    /// - Parameters:
    ///   - day: 탭한 셀의 일
    ///   - eventList: 탭한 셀의 일에 해당하는 `CalendarEvent` 배열
    func didSelectCell(day: Int, eventList: [CalendarEvent]) {
        let calendarEventListModalVC = CalendarEventListViewController(day: day)
        calendarEventListModalVC.delegate = self
        
        if let sheet = calendarEventListModalVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        self.present(calendarEventListModalVC, animated: true)
        
    }
    
    func didFilterButtonTap() {
        let filterModalVC = FilterViewController()
        
        if let sheet = filterModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        self.present(filterModalVC, animated: true)
    }
    
    func populateDataSource() {
        for event in calendarEventMockList {
            guard let eventDate = dataSourceDateFormatter.date(from: event.eventDate) else { continue }
            personalEventDataSource[eventDate, default: []].append(event)
        }
    }
}

// MARK: - JTACMonthViewDataSource

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        let startDate = dataSourceDateFormatter.date(from: "\(CalendarRange.startYear.rawValue)년 1월 1일")
        let endDate = dataSourceDateFormatter.date(from: "\(CalendarRange.endYear.rawValue)년 12월 31일")
        
        let parameter = ConfigurationParameters(startDate: startDate ?? .distantPast,
                                                endDate: endDate ?? .distantFuture,
                                                generateInDates: .forAllMonths,
                                                generateOutDates: .tillEndOfRow)
        
        return parameter
    }
}

// MARK: - JTACMonthViewDelegate

extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarEventList: personalEventDataSource[date] ?? [])
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else { return JTACDayCell() }
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        calendarView.setMonthLabel(date: date)
    }
    
    // 이미 선택된 셀인 경우 ➡️ 선택 해제
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if cellState.isSelected {
            calendar.deselect(dates: [date])
            return false
        }
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarEventList: personalEventDataSource[date] ?? [])
        let day = Calendar.current.component(.day, from: date)
        switch calendarMode.value {
        case .personal:
            didSelectCell(day: day, eventList: personalEventDataSource[date] ?? [])
        case .shared:
            didSelectCell(day: day, eventList: sharedEventDataSource[date] ?? [])
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarEventList: personalEventDataSource[date] ?? [])
    }
}

// MARK: - CalendarEventListVCDelegate

extension CalendarViewController: CalendarEventListVCDelegate {
    func viewWillDisappear() {
        calendarView.getJTACalendar.deselectAllDates()
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
