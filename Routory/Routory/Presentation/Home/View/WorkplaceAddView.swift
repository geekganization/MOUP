//
//  WorkplaceAddView.swift
//  Routory
//
//  Created by shinyoungkim on 6/13/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceAddView: UIView {
    
    // MARK: - UI Components
    
    private let handleView = UIView().then {
        $0.backgroundColor = .gray400
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "새 근무지 등록"
        $0.font = .headBold(18)
        $0.setLineSpacing(.headBold)
        $0.textColor = .gray900
    }
    
    private let seperatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let titleView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let inviteCodeIcon = UIImageView().then {
        $0.image = UIImage.mail
    }
    
    private let inviteCodeTitleLabel = UILabel().then {
        $0.text = "초대 코드 입력하기"
        $0.font = .bodyMedium(14)
        $0.textColor = .gray900
    }
    
    private let inviteCodeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let manualInputIcon = UIImageView().then {
        $0.image = UIImage.plus
    }
    
    private let manualInputTitleLabel = UILabel().then {
        $0.text = "직접 입력하기"
        $0.font = .bodyMedium(14)
        $0.textColor = .gray900
    }
    
    private let manualInputStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WorkplaceAddView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        titleView.addSubviews(
            handleView,
            titleLabel,
            seperatorView
        )
        
        inviteCodeStackView.addArrangedSubviews(
            inviteCodeIcon,
            inviteCodeTitleLabel
        )
        
        manualInputStackView.addArrangedSubviews(
            manualInputIcon,
            manualInputTitleLabel
        )
        
        addSubviews(
            titleView,
            inviteCodeStackView,
            manualInputStackView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(12)
            $0.leading.equalTo(16)
        }
        
        seperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        inviteCodeIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.height.width.equalTo(20)
        }
        
        inviteCodeStackView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        manualInputIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.height.width.equalTo(20)
        }
        
        manualInputStackView.snp.makeConstraints {
            $0.top.equalTo(inviteCodeStackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
    }
}
