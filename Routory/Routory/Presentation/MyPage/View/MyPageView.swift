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
    
    // MARK: - Properties
    
    var onEditButtonTapped: (() -> Void)?
    
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
        $0.text = "MOUP"
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
    
    private let editButton = UIButton().then {
        $0.setImage(UIImage.editButton, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    private let menuList = MyPageMenuListView()
    
    private let logoutButton = UIButton().then() {
        $0.titleLabel?.font = .buttonSemibold(16)
        $0.setTitleColor(UIColor.primary600, for: .normal)
        $0.setTitle("로그아웃", for: .normal)
        $0.backgroundColor = .primary50
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary600.cgColor
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var menuListView: MyPageMenuListView { menuList }
    
    var logoutButtonView: UIButton { logoutButton }
    
    var EditButtonView: UIButton { editButton }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(user: User) {
        nameLabel.text = user.userName
        roleLabel.text = user.role == "worker" ? "알바생" : "사장님"
        profileImageView.image = user.role == "worker" ? UIImage.alba : UIImage.owner
    }
}

private extension MyPageView {    
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
        setActions()
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
            editButton,
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
        
        editButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.leading.equalTo(nameRoleStackView.snp.trailing).offset(4)
            $0.centerY.equalTo(nameLabel.snp.centerY)
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
    
    // MARK: - setActions
    func setActions() {
        editButton.addTarget(
            self,
            action: #selector(editButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func editButtonDidTap() {
        onEditButtonTapped?()
    }
}
