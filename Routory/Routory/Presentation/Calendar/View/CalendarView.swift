//
//  CalendarView.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

import JTAppleCalendar
import SnapKit
import Then

final class CalendarView: UIView {
    
    // MARK: - Properties
    
    /// `CalendarHeaderView`에서 `yearMonthLabel`의 연/월 형식을 만들기 위한 `DateFormatter`
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy. MM"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    // MARK: - UI Components
    
    private let calendarHeaderView = CalendarHeaderView()
    
    private let dayOfTheWeekHStack = DayOfTheWeekHStackView()
    
    private let jtaCalendar = JTACMonthView()
    
    // MARK: - Getter
    
    var getDateFormatter: DateFormatter {
        return dateFormatter
    }
    
    var getCalendarHeaderView: CalendarHeaderView {
        return calendarHeaderView
    }
    
    var getJTACalendar: JTACMonthView {
        return jtaCalendar
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setCalendarView()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension CalendarView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setDelegates()
    }
    
    func setHierarchy() {
        self.addSubviews(calendarHeaderView,
                         dayOfTheWeekHStack,
                         jtaCalendar)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
        
        jtaCalendar.minimumLineSpacing = 0
        jtaCalendar.minimumInteritemSpacing = 0
        jtaCalendar.scrollDirection = .horizontal
        jtaCalendar.isPagingEnabled = true
        jtaCalendar.showsHorizontalScrollIndicator = false
        jtaCalendar.showsVerticalScrollIndicator = false
    }
    
    func setConstraints() {
        calendarHeaderView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        
        dayOfTheWeekHStack.snp.makeConstraints {
            $0.top.equalTo(calendarHeaderView.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(20)
        }
        
        jtaCalendar.snp.makeConstraints {
            $0.top.equalTo(dayOfTheWeekHStack.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    func setDelegates() {
        jtaCalendar.calendarDataSource = self
        jtaCalendar.calendarDelegate = self
    }
}

// MARK: - JTAppleCalendar Methods

private extension CalendarView {
    /// `JTACMonthView`에 `JTACalendarDayCell`을 `register`하고 현재 날짜로 스크롤한 후, `CalendarHeaderView`의 초기 `yearMonthLabel`을 설정합니다.
    func setCalendarView() {
        jtaCalendar.register(JTACalendarDayCell.self, forCellWithReuseIdentifier: JTACalendarDayCell.identifier)
        
        jtaCalendar.scrollToDate(.now, animateScroll: false)
        
        jtaCalendar.visibleDates { [weak self] visibleDates in
            guard let self, let date = visibleDates.monthDates.first?.date else { return }
            self.setMonthLabel(date: date)
        }
    }
    
    /// 지정된 날짜를 이용해 `CalendarHeaderView`의 `yearMonthLabel`을 업데이트합니다.
    ///
    /// - Parameter date: 레이블에 표시할 날짜.
    func setMonthLabel(date: Date) {
        calendarHeaderView.getYearMonthLabel.text = dateFormatter.string(from: date)
    }
    
    /// 셀의 색상 및 선택 상태를 종합적으로 구성하는 진입점 메서드입니다.
    ///
    /// - Parameters:
    ///   - cell: 구성할 `JTACDayCell` 인스턴스 (`JTACalendarDayCell`로 캐스팅됨).
    ///   - cellState: 셀의 상태 정보를 담은 `CellState`.
    func handleConfiguration(cell: JTACDayCell?, cellState: CellState) {
        guard let cell = cell as? JTACalendarDayCell else { return }
        handleCellColor(cell: cell, cellState: cellState)
        handleCellSelection(cell: cell, cellState: cellState)
    }
    
    /// 셀에서 `seperatorView`를 제외한 UI 컴포넌트 표시 여부 및 상호작용 가능 여부를 설정합니다.
    ///
    /// - Parameters:
    ///   - cell: DayCell 인스턴스.
    ///   - cellState: 셀의 상태 정보. `.thisMonth`인 경우에만 표시됩니다.
    func handleCellColor(cell: JTACalendarDayCell, cellState: CellState) {
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
    
    /// 셀 선택 상태에 따라 `selectedView`의 숨김 여부를 설정합니다.
    ///
    /// - Parameters:
    ///   - cell: `DayCell` 인스턴스.
    ///   - cellState: 셀의 상태 정보. `isSelected`가 `true`인 경우 `selectedView`가 표시됩니다.
    func handleCellSelection(cell: JTACalendarDayCell, cellState: CellState) {
        if cellState.isSelected {
            cell.getSelectedView.isHidden = false
        } else {
            cell.getSelectedView.isHidden = true
        }
    }
}

// MARK: - JTACMonthViewDataSource

extension CalendarView: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let startDate = dateFormatter.date(from: "\(JTACalendarRange.startYear.rawValue) 01 01")
        let endDate = dateFormatter.date(from: "\(JTACalendarRange.endYear.rawValue) 12 31")
        
        let parameter = ConfigurationParameters(startDate: startDate ?? .distantPast,
                                                endDate: endDate ?? .distantFuture,
                                                generateInDates: .forAllMonths,
                                                generateOutDates: .tillEndOfRow)
        
        return parameter
    }
}

// MARK: - JTACMonthViewDelegate

extension CalendarView: JTACMonthViewDelegate {
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        self.handleConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: JTACalendarDayCell.identifier, for: indexPath) as? JTACalendarDayCell else { return JTACDayCell() }
        
        let isToday = (Calendar.current.isDateInToday(date) ? true : false)
        cell.update(date: cellState.text, isSaturday: cellState.day.rawValue == 7, isSunday: cellState.day.rawValue == 1, isToday: isToday, eventList: [calendarEventMock])
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        setMonthLabel(date: date)
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
        dump(date)
        handleConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleConfiguration(cell: cell, cellState: cellState)
    }
}
