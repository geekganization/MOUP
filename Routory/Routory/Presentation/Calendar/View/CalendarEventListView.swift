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
    
    private let eventTableView = EventTableView(frame: .zero, style: .plain)
    
    private let assignButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("근무 등록하기", attributes: .init([.font: UIFont.buttonSemibold(18), .foregroundColor: UIColor.white]))
        
        $0.configuration = config
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setEventTableView()
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
        self.addSubviews(eventTableView,
                         assignButton)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray400.cgColor
    }
    
    func setConstraints() {
        eventTableView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
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

private extension CalendarEventListView {
    func setEventTableView() {
        
    }
}
