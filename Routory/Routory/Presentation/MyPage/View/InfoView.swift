//
//  InfoView.swift
//  Routory
//
//  Created by shinyoungkim on 6/10/25.
//

import UIKit
import Then
import SnapKit

final class InfoView: UIView {

    // MARK: - UI Components
    
    private let navigationBar = MyPageNavigationBar(title: "정보")
    
    private let menuList = MyPageMenuListView()
    
    private let appVersionTitleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = UIColor.gray900
        $0.text = "앱 버전"
    }
    
    private let appVersionLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = UIColor.gray700
        $0.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private let appVersionView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    private let appVersionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalCentering

    }
    
    // MARK: - Getter
    
    var navigationBarView: MyPageNavigationBar {
        return navigationBar
    }
    
    var menuListView: MyPageMenuListView {
        return menuList
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

private extension InfoView {    
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        appVersionView.addSubviews(
            appVersionTitleLabel,
            appVersionLabel
        )
        
        addSubviews(
            navigationBar,
            menuList,
            appVersionView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .systemBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        menuList.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48 * 3)
        }
        
        appVersionTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        appVersionLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        appVersionView.snp.makeConstraints {
            $0.top.equalTo(menuList.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }
}
