//
//  MyPageView.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit
import Then
import SnapKit

final class MyPageView: UIView {
    
    // MARK: - UI Components
    
    private let profileImageFrame = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .primary50
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.text = "김알바"
    }
    
    private let roleLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.text = "알바생"
    }
    
    private let nameRoleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .leading
    }
    
    let menuList = MyPageMenuListView()
    
    let logoutButton = UIButton().then() {
        $0.titleLabel?.font = .buttonSemibold(16)
        $0.setTitleColor(UIColor.primary600, for: .normal)
        $0.setTitle("로그아웃", for: .normal)
        $0.backgroundColor = .primary50
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary600.cgColor
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(user: DummyUser) {
        nameLabel.text = user.name
        roleLabel.text = user.role
        profileImageView.image = user.role == "알바생" ? UIImage(named: "Alba") : UIImage(named: "Owner")
    }
}

extension MyPageView {
    
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        profileImageFrame.addSubview(profileImageView)
        nameRoleStackView.addArrangedSubviews(
            nameLabel,
            roleLabel
        )
        addSubviews(
            profileImageFrame,
            nameRoleStackView,
            menuList,
            logoutButton
        )
    }

    // MARK: - setConstraints
    func setConstraints() {
        profileImageFrame.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.equalTo(57)
            $0.height.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(profileImageFrame.snp.bottom).offset(2)
        }
        
        nameRoleStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageFrame.snp.centerY)
            $0.leading.equalTo(profileImageFrame.snp.trailing).offset(32)
        }
        
        menuList.snp.makeConstraints {
            $0.top.equalTo(profileImageFrame.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48 * 4)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(menuList.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
}
