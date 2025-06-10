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
    
    private let calendarHeaderView = CalendarHeaderView()
    
    private let dayOfTheWeekHStack = DayOfTheWeekHStackView()
    
    private let jtaCalendar = JTACMonthView()
    
    // MARK: - Getter
    
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
    }
    
    func setHierarchy() {
        self.addSubviews(calendarHeaderView,
                         dayOfTheWeekHStack,
                         jtaCalendar)
    }
    
    func setStyles() {
        jtaCalendar.minimumLineSpacing = 0
        jtaCalendar.minimumInteritemSpacing = 0
        jtaCalendar.isPagingEnabled = true
        jtaCalendar.scrollDirection = .horizontal
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
}
