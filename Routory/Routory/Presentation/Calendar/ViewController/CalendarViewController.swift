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
    
    // MARK: - Properties
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - UI Components
    
    private let calendarView = CalendarView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setCalendarView()
    }
}

// MARK: - UI Methods

private extension CalendarViewController {
    func configure() {
        setStyles()
        setDelegates()
    }
    
    func setStyles() {
        self.view.backgroundColor = .systemBackground
    }
    
    func setDelegates() {
        calendarView.getJTACalendar.calendarDataSource = self
        calendarView.getJTACalendar.calendarDelegate = self
    }
}

// MARK: - JTAppleCalendar Methods

private extension CalendarViewController {
    func setCalendarView() {
        calendarView.getJTACalendar.register(DayCell.self, forCellWithReuseIdentifier: DayCell.identifier)
        
        calendarView.getJTACalendar.scrollToDate(Date(), animateScroll: false)
        
        calendarView.getJTACalendar.visibleDates { [weak self] visibleDates in
            guard let self, let date = visibleDates.monthDates.first?.date else { return }
            self.setMonthLabel(date: date)
        }
    }
    
    func setMonthLabel(date: Date) {
        dateFormatter.dateFormat = "yyyy. MM"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        calendarView.getCalendarHeaderView.getYearMonthLabel.text = dateFormatter.string(from: date)
    }
    
    func handleConfiguration(cell: JTACDayCell?, cellState: CellState) {
        guard let cell = cell as? DayCell else { return }
        handleCellColor(cell: cell, cellState: cellState)
        handleCellSelection(cell: cell, cellState: cellState)
    }
    
    func handleCellColor(cell: DayCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.getDateLabel.isHidden = false
            cell.getSelectedView.isHidden = false
            cell.isUserInteractionEnabled = true
        } else {
            cell.getDateLabel.isHidden = true
            cell.getSelectedView.isHidden = true
            cell.isUserInteractionEnabled = false
        }
    }
    
    func handleCellSelection(cell: DayCell, cellState: CellState) {
        if cellState.isSelected {
            cell.getSelectedView.isHidden = false
        } else {
            cell.getSelectedView.isHidden = true
        }
    }
}

// MARK: - JTACMonthViewDataSource

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        
        let startDate = dateFormatter.date(from: "2001 01 01")
        let endDate = dateFormatter.date(from: "2100 12 31")
        
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
        self.handleConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DayCell.identifier, for: indexPath) as? DayCell else { return JTACDayCell() }
        
        let isToday = (Calendar.current.isDateInToday(date) ? true : false)
        cell.update(date: cellState.text, isSunday: cellState.day.rawValue == 1, isToday: isToday)
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        setMonthLabel(date: date)
    }
    
    /// 이미 선택된 셀인 경우 선택 해제
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if cellState.isSelected {
            calendar.deselect(dates: [date])
            return false
        }
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleConfiguration(cell: cell, cellState: cellState)
    }
}
