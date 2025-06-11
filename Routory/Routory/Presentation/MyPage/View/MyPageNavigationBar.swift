//
//  MyPageNavigationBar.swift
//  Routory
//
//  Created by shinyoungkim on 6/10/25.
//

import UIKit
import Then

final class MyPageNavigationBar: UIView {
    
    // MARK: - Properties
    
    private let title: String
    
    // MARK: - UI Components
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "BackButton"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.setLineSpacing(.headBold)
        $0.textColor = UIColor.gray900
    }
    
    // MARK: - Getter
    
    var backButtonView: UIButton {
        return backButton
    }
    
    // MARK: - Initializer
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyPageNavigationBar {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            backButton,
            titleLabel
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .systemBackground
        titleLabel.text = title
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
