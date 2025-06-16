//
//  CalendarEventListView.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class CalendarEventListView: UIView {
    
    // MARK: - UI Components
    
    private let grabberView = GrabberView()
    
    private let titleLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.textColor = .gray900
    }
    
    private let eventTableView = UITableView().then {
        $0.register(EventCell.self, forCellReuseIdentifier: EventCell.identifier)
        
        $0.rowHeight = 84  // 64 + 16(셀 간격)
        $0.separatorStyle = .none
    }
    
    private let assignButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("근무 등록하기", attributes: .init([.font: UIFont.buttonSemibold(18), .foregroundColor: UIColor.white]))
        
        $0.configuration = config
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var getTitleLabel: UILabel { titleLabel }
    var getEventTableView: UITableView { eventTableView }
    
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
        assignButton.layer.cornerRadius = 12
    }
}

// MARK: - UI Methods

private extension CalendarEventListView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    func setHierarchy() {
        self.addSubviews(grabberView,
                         titleLabel,
                         eventTableView,
                         assignButton)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray400.cgColor
    }
    
    func setConstraints() {
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(16)
        }
        
        eventTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(assignButton.snp.top).offset(-12)
        }
        
        assignButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(44)
        }
    }
    
    func setActions() {
        
    }
    
    func setBinding() {
        
    }
}
