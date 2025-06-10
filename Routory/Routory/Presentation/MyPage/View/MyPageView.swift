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
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .gray
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
    
    let myPageTableView = UITableView(frame: .zero, style: .plain).then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.clipsToBounds = true
    }
    
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
}

extension MyPageView {
    
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        nameRoleStackView.addArrangedSubviews(
            nameLabel,
            roleLabel
        )
        addSubviews(
            profileImageView,
            nameRoleStackView,
            myPageTableView,
            logoutButton
        )
    }

    // MARK: - setConstraints
    func setConstraints() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        nameRoleStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView.snp.centerY)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(32)
        }
        
        myPageTableView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48 * 4)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(myPageTableView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
}
