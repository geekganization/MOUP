//
//  NotificationSettingsView.swift
//  Routory
//
//  Created by shinyoungkim on 6/17/25.
//

import UIKit
import SnapKit
import Then

final class NotificationSettingsView: UIView {
    
    // MARK: - UI Components
    
    private let navigationBar = MyPageNavigationBar(title: "알림 설정")
    
    private let notificationLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
        $0.text = "푸시 알림"
    }
    
    private let notificationSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = .primary500
    }
    
    private let notificationView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    // MARK: - Getter
    
    var navigationBarView: MyPageNavigationBar {
        return navigationBar
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NotificationSettingsView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        notificationView.addSubviews(
            notificationLabel,
            notificationSwitch
        )
        addSubviews(
            navigationBar,
            notificationView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        notificationLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        notificationSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        notificationView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(55)
        }
    }
}
