//
//  CalendarEventVStackView.swift
//  Routory
//
//  Created by 서동환 on 6/13/25.
//

import UIKit

import SnapKit
import Then

final class CalendarEventVStackView: UIStackView {
    
    // MARK: - UI Components
    
    private let workHourOrNameLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textAlignment = .left
    }
    
    private let dailyWageLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textAlignment = .left
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Methods
    
    func update(workHour: Double, workerName: String, dailyWage: Int?, calendarMode: CalendarMode, color: String) {
        let workHourStr = String(format: "%.1f", workHour)
        if calendarMode == .shared {
            workHourOrNameLabel.text = workerName
        } else if workHourStr.last == "0" {
            workHourOrNameLabel.text = "\(workHourStr.prefix(1))시간"
        } else {
            workHourOrNameLabel.text = "\(workHourStr)시간"
        }
        
        if let dailyWage {
            // 시급
            dailyWageLabel.text = NumberFormatter.decimalFormatter.string(for: Int(dailyWage))
        } else {
            // 고정급
            dailyWageLabel.text = "고정급"
        }
        dailyWageLabel.isHidden = (calendarMode == .shared)
        
        // TODO: color 설정
        self.backgroundColor = .primary100
        workHourOrNameLabel.textColor = .primary600
        dailyWageLabel.textColor = .primary600
    }
}

// MARK: - UI Methods

private extension CalendarEventVStackView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addArrangedSubviews(workHourOrNameLabel,
                                 dailyWageLabel)
    }
    
    func setStyles() {
        self.axis = .vertical
        self.spacing = 0
        self.layoutMargins = .init(top: 0, left: 2, bottom: 0, right: 0)
        self.isLayoutMarginsRelativeArrangement = true
        self.layer.cornerRadius = 4
    }
    
    func setConstraints() {
        workHourOrNameLabel.snp.makeConstraints {
            $0.height.equalTo(17)
        }
        
        dailyWageLabel.snp.makeConstraints {
            $0.height.equalTo(17)
        }
    }
}
