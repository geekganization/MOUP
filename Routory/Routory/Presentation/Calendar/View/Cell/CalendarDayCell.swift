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
        $0.layer.cornerRadius = 10
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
    
    func update(date: String, isSaturday: Bool, isSunday: Bool, isToday: Bool, workerName: String, calendarMode: CalendarMode, calendarModelList: [CalendarModel]?) {
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
        
        if let calendarModelList {
            if calendarModelList.isEmpty {
                eventVStackView.isHidden = true
            } else {
                eventVStackView.isHidden = false
                
                if (calendarMode == .shared) && calendarModelList.count > 3 {
                    otherEventLabel.text = "+\(calendarModelList.count - 3)"
                    otherEventLabel.isHidden = false
                }
                for (index, model) in calendarModelList.enumerated() {
                    if index > ((calendarMode == .shared) ? 2 : 1) {
                        break
                    } else {
                        guard let eventView = eventVStackView.subviews[index] as? CalendarEventVStackView else { continue }
                        
                        let event = model.eventInfo.calendarEvent
                        let workHour = DateFormatter.hourDiffDecimal(from: event.startTime, to: event.endTime, break: model.breakTimeMinutes.rawValue)
                        // TODO: isShared == true일 때 이름 표시
                        // TODO: color 표시
                        if model.wageType == "시급" {
                            let dailyWage = Int(Double(model.wage) * (workHour?.decimal ?? 0.0))
                            eventView.update(workHour: workHour?.decimal ?? 0, workerName: "WIP", dailyWage: dailyWage, calendarMode: calendarMode, color: "red")
                        } else if model.wageType == "고정" {
                            eventView.update(workHour: workHour?.decimal ?? 0, workerName: "WIP", dailyWage: nil, calendarMode: calendarMode, color: "red")
                        }
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
            $0.width.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }
        
        eventVStackView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
    }
}
