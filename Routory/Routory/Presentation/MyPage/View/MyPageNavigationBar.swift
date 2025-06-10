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
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "BackButton"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.setLineSpacing(.headBold)
        $0.textColor = UIColor.gray900
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

extension MyPageNavigationBar {
    // MARK: - configure
    private func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    private func setHierarchy() {
        addSubviews(
            backButton,
            titleLabel
        )
    }
    
    // MARK: - setStyles
    private func setStyles() {
        backgroundColor = .systemBackground
        titleLabel.text = title
    }
    
    // MARK: - setConstraints
    private func setConstraints() {
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
