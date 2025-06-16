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
    
    private let workplaceLabel = UILabel().then {
        $0.text = "맥도날드"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let workHourLabel = UILabel().then {
        $0.text = "09:00 ~ 19:00 (10시간)"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fillEqually
    }
    
    private let dailyWageLabel = UILabel().then {
        $0.text = "100,000원"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
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
        
        self.backgroundView = ColorBorderView(frame: self.contentView.bounds, borderColor: .red)
        self.backgroundView?.frame = self.contentView.frame
    }
    
    
    // MARK: - Methods
    
    func update(workplace: String, startTime: String, endTime: String, dailyWage: String) {
        
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
        self.contentView.addSubviews(labelStackView,
                                     dailyWageLabel)
        
        labelStackView.addArrangedSubviews(workplaceLabel,
                                           workHourLabel)
    }
    
    func setStyles() {
        self.selectionStyle = .none
    }
    
    func setConstraints() {
        labelStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        dailyWageLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
}
