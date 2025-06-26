//
//  EventCell.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import UIKit

import SnapKit
import Then

final class EventCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: EventCell.self)
    
    // MARK: - UI Components
    
    private let colorBorderView = ColorBorderView(frame: .zero, borderColor: ._default)
    
    private let workplaceOrNameLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    /// 연동 표시 칩 `UILabel`
    private let sharedChipLabel = ChipLabel(title: "연동", color: .primary100, titleColor: .primary600)
    
    private let workplaceChipHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private let workHourLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let leadingVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    
    private let ellipsisButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .eventCellEllipsis.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        
        $0.configuration = config
    }
    
    private let dailyWageLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    // MARK: - Getter
    
    var getEllipsisButton: UIButton { ellipsisButton }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        
        self.backgroundView = colorBorderView
        self.backgroundView?.frame = self.contentView.frame
    }
    
    // MARK: - Methods
    
    func update(model: CalendarModel, calendarMode: CalendarMode) {
        colorBorderView.updateBorderColor(borderColor: model.color)
        
        if calendarMode == .personal {
            workplaceOrNameLabel.text = model.workplaceName
            dailyWageLabel.isHidden = false
        } else if calendarMode == .shared {
            workplaceOrNameLabel.text = model.userName
        }
        
        sharedChipLabel.isHidden = !model.isOfficial
        
        let startTime = model.eventInfo.calendarEvent.startTime
        let endTime = model.eventInfo.calendarEvent.endTime
        let workHour = DateFormatter.hourDiffDecimal(from: startTime, to: endTime, break: model.breakTimeMinutes.rawValue)
        if let hour = workHour?.hours,
           let min = workHour?.minutes {
            if min == 0 {
                workHourLabel.text = "\(startTime) ~ \(endTime) (\(hour)시간)"
            } else {
                workHourLabel.text = "\(startTime) ~ \(endTime) (\(hour)시간 \(min)분)"
            }
        }
        
        if let userId = UserManager.shared.firebaseUid {
            ellipsisButton.isHidden = !(model.eventInfo.calendarEvent.createdBy == userId)
            
            if model.wageType == "시급" {
                let dailyWage = Int(Double(model.wage ?? 0) * (workHour?.decimal ?? 0.0))
                let formatted = NumberFormatter.decimalFormatter.string(for: dailyWage) ?? "?"
                dailyWageLabel.text = "\(formatted)원"
                dailyWageLabel.isHidden = !(model.eventInfo.calendarEvent.createdBy == userId)
            } else if model.wageType == "고정" {
                dailyWageLabel.text = "고정급"
                dailyWageLabel.isHidden = !(model.eventInfo.calendarEvent.createdBy == userId)
            } else {
                dailyWageLabel.isHidden = true
            }
        } else {
            ellipsisButton.isHidden = true
            dailyWageLabel.isHidden = true
        }
    }
}

// MARK: - UI Methods

private extension EventCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.contentView.addSubviews(leadingVStackView, ellipsisButton,
                                     dailyWageLabel)
        
        workplaceChipHStackView.addArrangedSubviews(workplaceOrNameLabel, sharedChipLabel)
        
        leadingVStackView.addArrangedSubviews(workplaceChipHStackView,
                                              workHourLabel)
    }
    
    func setStyles() {
        self.selectionStyle = .none
    }
    
    func setConstraints() {
        leadingVStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        sharedChipLabel.snp.makeConstraints {
            $0.width.equalTo(37)
            $0.height.equalTo(18)
        }
        
        ellipsisButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(6)
            $0.width.equalTo(44)
            $0.height.equalTo(30)
        }
        
        dailyWageLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(24)
        }
    }
}
