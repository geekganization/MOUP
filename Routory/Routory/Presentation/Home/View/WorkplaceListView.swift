//
//  WorkplaceListView.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceListView: UIView {
    
    // MARK: - UI Components
    
    private let navigationBar = MyPageNavigationBar(title: "근무지")
    
    private let guideMessage = UILabel().then {
        $0.text = "연동할 근무지를 선택해주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    private let tableView = UITableView().then {
        $0.register(WorkplaceListTableViewCell.self, forCellReuseIdentifier: "WorkplaceListTableViewCell")
        $0.separatorStyle = .none
    }
    
    private let selectButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "적용하기"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .primary500
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSemibold(14)
            return outgoing
        }

        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var navigationBarView: MyPageNavigationBar { navigationBar }
    var workplaceTableView: UITableView { tableView }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WorkplaceListView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            guideMessage,
            tableView,
            selectButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
        }
        
        guideMessage.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(guideMessage.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(selectButton.snp.top).inset(12)
        }
        
        selectButton.snp.makeConstraints {
            $0.height.equalTo(45)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(46)
        }
    }
}
