//
//  CalendarDayCell.swift
//  Routory
//
//  Created by 서동환 on 6/10/25.
//

import UIKit

import JTAppleCalendar
import SnapKit
import Then

final class CalendarDayCell: JTACDayCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: CalendarDayCell.self)
    
    /// 근무 시간 계산용 `DateFormatter`
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = "HH:mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    // MARK: - UI Components
    
    private let seperatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let selectedView = UIView().then {
        $0.backgroundColor = .primary50
        $0.isHidden = true
    }
    
    private let dayLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10.5
    }
    
    private let firstEventStackView = CalendarEventVStackView()
    private let secondEventStackView = CalendarEventVStackView()
    private let thirdEventStackView = CalendarEventVStackView()
    private let otherEventLabel = OtherEventLabel()
    
    private let eventVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    // MARK: - Getter
    
    var getSelectedView: UIView { selectedView }
    
    var getDateLabel: UILabel { dayLabel }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.backgroundColor = .clear
    }
    
    // MARK: - Methods
    
    func update(date: String, isSaturday: Bool, isSunday: Bool, isToday: Bool, isShared: Bool, eventList: [CalendarEvent]?) {
        dayLabel.text = date
        dayLabel.textColor = isSunday ? .sundayText : .gray900
        
        if isToday {
            dayLabel.textColor = .white
            dayLabel.backgroundColor = .gray900
        } else if isSaturday {
            dayLabel.textColor = .saturdayText
        } else if isSunday {
            dayLabel.textColor = .sundayText
        } else {
            dayLabel.textColor = .gray900
        }
        
        eventVStackView.subviews.forEach { $0.isHidden = true }
        
        if let eventList {
            if eventList.isEmpty {
                eventVStackView.isHidden = true
            } else {
                eventVStackView.isHidden = false
                
                if isShared && eventList.count > 3 {
                    otherEventLabel.text = "+\(eventList.count - 3)"
                    otherEventLabel.isHidden = false
                }
                for (index, event) in eventList.enumerated() {
                    if index > (isShared ? 2 : 1) {
                        break
                    } else {
                        guard let eventView = eventVStackView.subviews[index] as? CalendarEventVStackView else { continue }
                        // TODO: 캘린더가 isShared인지 확인 필요
                        let workHour = hourDiffDecimal(from: event.startTime, to: event.endTime)
                        // TODO: dailyWage 계산 필요
                        eventView.update(workHourOrName: "\(workHour?.hours ?? 0)", dailyWage: "100,000", isShared: isShared, color: "red")
                        eventView.isHidden = false
                    }
                }
            }
        }
    }
}

// MARK: - UI Methods

private extension CalendarDayCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.contentView.addSubviews(seperatorView,
                         selectedView,
                         dayLabel,
                         eventVStackView)
        
        eventVStackView.addArrangedSubviews(firstEventStackView,
                                            secondEventStackView,
                                            thirdEventStackView,
                                            otherEventLabel)
    }
    
    func setStyles() {
        self.contentView.backgroundColor = .primaryBackground
    }
    
    func setConstraints() {
        seperatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        selectedView.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom).offset(4)
            $0.width.height.equalTo(21)
            $0.centerX.equalToSuperview()
        }
        
        eventVStackView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
    }
}

// MARK: - Private Methods

private extension CalendarDayCell {
    func hourDiffDecimal(from start: String, to end: String) -> (hours: Int, minutes: Int, decimal: Double)? {
        guard let startDate = dateFormatter.date(from: start),
              let endDate = dateFormatter.date(from: end) else { return nil }
        
        let todayOverEnd = endDate < startDate ? Calendar.current.date(byAdding: .day, value: 1, to: endDate) ?? endDate : endDate
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: todayOverEnd)
        
        let h = components.hour ?? 0
        let m = components.minute ?? 0
        let decimalHours = Double(h) + Double(m) / 60.0
        
        return (h, m, decimalHours)
    }
}
