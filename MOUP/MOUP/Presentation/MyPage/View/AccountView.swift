//
//  AccountView.swift
//  Routory
//
//  Created by shinyoungkim on 6/11/25.
//

import UIKit
import Then
import SnapKit

final class AccountView: UIView {
    
    // MARK: - Properties
    
    var onDeleteAccountTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let navigationBar = MyPageNavigationBar(title: "계정")
    
    private let deleteAccountLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .primary500
        $0.text = "탈퇴하기"
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = UIImage.chevronRight
        $0.contentMode = .scaleAspectFit
    }
    
    private let deleteAccountView = UIView().then {
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

private extension AccountView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    func setHierarchy() {
        deleteAccountView.addSubviews(
            deleteAccountLabel,
            rightArrow
        )
        addSubviews(
            navigationBar,
            deleteAccountView
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
        
        deleteAccountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        rightArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        deleteAccountView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }
    
    func setActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped))
        deleteAccountView.isUserInteractionEnabled = true
        deleteAccountView.addGestureRecognizer(tapGesture)
    }

    @objc func deleteAccountTapped() {
        onDeleteAccountTapped?()
    }
}
