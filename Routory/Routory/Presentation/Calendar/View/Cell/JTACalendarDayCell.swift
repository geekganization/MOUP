//
//  JTACalendarDayCell.swift
//  Routory
//
//  Created by 서동환 on 6/10/25.
//

import UIKit

import JTAppleCalendar
import SnapKit
import Then

final class JTACalendarDayCell: JTACDayCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: JTACalendarDayCell.self)
    
    // MARK: - UI Components
    
    private let seperatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let selectedView = UIView().then {
        $0.backgroundColor = .primary50
        $0.isHidden = true
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var getSelectedView: UIView {
        return selectedView
    }
    
    var getDateLabel: UILabel {
        return dateLabel
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
    
    // MARK: - Lifecycle
        
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.layer.cornerRadius = dateLabel.frame.height / 2
    }
    
    // MARK: - Methods
    
    func update(date: String, isSunday: Bool, isToday: Bool) {
        dateLabel.text = date
        dateLabel.textColor = isSunday ? .sundayText : .gray900
        
        if isToday {
            dateLabel.textColor = .primaryBackground
            dateLabel.backgroundColor = .gray900
        } else if isSunday {
            dateLabel.textColor = .sundayText
        } else {
            dateLabel.textColor = .gray900
            dateLabel.backgroundColor = .clear
        }
    }
}

private extension JTACalendarDayCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(seperatorView,
                         selectedView,
                         dateLabel)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
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
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom).offset(4)
            $0.width.height.equalTo(22)
            $0.centerX.equalToSuperview()
        }
    }
}
