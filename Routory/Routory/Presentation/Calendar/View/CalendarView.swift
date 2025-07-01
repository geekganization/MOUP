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
    
    // MARK: - UI Components
    
    private let navigationBar = BaseNavigationBar(title: "캘린더").then {
        $0.configureBackButton(isHidden: true)
        $0.configureRightButton(icon: nil, title: "오늘")
    }
    
    private let calendarHeaderView = CalendarHeaderView()
    
    private let dayOfTheWeekHStack = DayOfTheWeekHStackView()
    
    private let jtaCalendar = JTACMonthView()
    
    // MARK: - Getter
    
    var getNavigationBar: BaseNavigationBar { navigationBar }
    var getCalendarHeaderView: CalendarHeaderView { calendarHeaderView }
    var getJTACalendar: JTACMonthView { jtaCalendar }
    
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
// MARK: - UI Methods

private extension CalendarView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(navigationBar,
                         calendarHeaderView,
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
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        calendarHeaderView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
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
}

// MARK: - JTAppleCalendar Methods

extension CalendarView {
    /// `JTACMonthView`에 `JTACalendarDayCell`을 `register`하고 현재 날짜로 스크롤한 후, `CalendarHeaderView`의 초기 `yearMonthLabel`을 설정합니다.
    func setCalendarView() {
        jtaCalendar.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        
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
        let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
        var config = calendarHeaderView.getYearMonthButton.configuration
        config?.attributedTitle = AttributedString(dateStr, attributes: .init([.font: UIFont.headBold(20), .foregroundColor: UIColor.gray900]))
        calendarHeaderView.getYearMonthButton.configuration = config
    }
    
    /// 셀의 색상 및 선택 상태를 종합적으로 구성하는 진입점 메서드입니다.
    ///
    /// - Parameters:
    ///   - cell: 구성할 `JTACDayCell` 인스턴스 (`JTACalendarDayCell`로 캐스팅됨).
    ///   - cellState: 셀의 상태 정보를 담은 `CellState`.
    func configureCell(cell: JTACDayCell?, date: Date, cellState: CellState, calendarMode: CalendarMode, modelList: [CalendarModel]) {
        guard let cell = cell as? CalendarDayCell else { return }
        handleCellColor(cell: cell, cellState: cellState)
        handleCellSelection(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode, modelList: modelList)
    }
    
    /// 셀에서 `seperatorView`를 제외한 UI 컴포넌트 표시 여부 및 상호작용 가능 여부를 설정합니다.
    ///
    /// - Parameters:
    ///   - cell: DayCell 인스턴스.
    ///   - cellState: 셀의 상태 정보. `.thisMonth`인 경우에만 표시됩니다.
    func handleCellColor(cell: CalendarDayCell, cellState: CellState) {
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
    func handleCellSelection(cell: CalendarDayCell, cellState: CellState) {
        if cellState.isSelected {
            cell.getSelectedView.isHidden = false
        } else {
            cell.getSelectedView.isHidden = true
        }
    }
    
    func handleCellEvents(cell: CalendarDayCell, date: Date, cellState: CellState, calendarMode: CalendarMode, modelList: [CalendarModel]) {
        var calendar = Calendar.current
        calendar.timeZone = .autoupdatingCurrent
        let isToday = calendar.isDateInToday(date) ? true : false
        
        cell.update(date: cellState.text,
                    isSaturday: cellState.day.rawValue == 7,
                    isSunday: cellState.day.rawValue == 1,
                    isToday: isToday,
                    calendarMode: calendarMode,
                    modelList: modelList)
    }
}
