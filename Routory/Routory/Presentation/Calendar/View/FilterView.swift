//
//  FilterView.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import UIKit

import SnapKit
import Then

final class FilterView: UIView {
    
    // MARK: - UI Components
    
    private let grabberView = GrabberView()
    
    private let titleLabel = UILabel().then {
        $0.text = "필터"
        $0.font = .headBold(20)
        $0.textColor = .gray900
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let headerLabel = UILabel().then {
        // TODO: 알바생인지 사장님인지에 따라 바뀌어야 함
        $0.text = "나의 근무지"
        $0.textColor = .gray900
        $0.font = .headBold(16)
    }
    
    private let workplaceTableView = UITableView().then {
        $0.register(WorkplaceCell.self, forCellReuseIdentifier: WorkplaceCell.identifier)
        
        $0.separatorStyle = .none
        $0.rowHeight = 52  // 40 + 12(셀 간격)
        $0.sectionHeaderTopPadding = 0.0
    }
    
    private let applyButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("적용하기", attributes: .init([.font: UIFont.buttonSemibold(18), .foregroundColor: UIColor.white]))
        
        $0.configuration = config
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var getWorkplaceTableView: UITableView { workplaceTableView }
    var getApplyButton: UIButton { applyButton }
    
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
        applyButton.layer.cornerRadius = 12
    }
}

private extension FilterView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBinding()
    }
    
    func setHierarchy() {
        self.addSubviews(grabberView,
                         titleLabel,
                         separatorView,
                         headerLabel,
                         workplaceTableView,
                         applyButton)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
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
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(1)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(12)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(16)
        }
        
        workplaceTableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(applyButton.snp.top).offset(-12)
        }
        
        applyButton.snp.makeConstraints {
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
