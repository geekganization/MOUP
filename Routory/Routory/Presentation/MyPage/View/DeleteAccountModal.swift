//
//  DeleteAccountModal.swift
//  Routory
//
//  Created by shinyoungkim on 6/11/25.
//

import UIKit
import Then
import SnapKit

final class DeleteAccountModal: UIView {
    
    // MARK: - Properties
    
    var onRequestDismiss: (() -> Void)?
    var onRequestDeleteAccount: (() -> Void)?
    
    // MARK: - UI Components
    
    private let handleView = UIView().then {
        $0.backgroundColor = .gray400
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "송알바님, 탈퇴 전에 확인해주세요!"
        $0.font = .headBold(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "탈퇴일 포함 3일 동안은 재가입할 수 없으며,\n재가입하더라도 이전 이용 내역은 복구되지 않습니다."
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let confirmLabel = UILabel().then {
        $0.text = "탈퇴를 진행할까요?"
        $0.font = .headBold(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
    }
    
    private let deleteAccountNoticeStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
    }
    
    private let cancelButton = UIButton().then {
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.gray600, for: .normal)
        $0.setTitle("아뇨, 안할래요", for: .normal)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let deleteAccountButton = UIButton().then {
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("탈퇴할게요", for: .normal)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var cancelButtonView: UIButton { cancelButton }
    var deleteAccountButtonView: UIButton { deleteAccountButton }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension DeleteAccountModal {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        deleteAccountNoticeStackView.addArrangedSubviews(
            titleLabel,
            descriptionLabel,
            confirmLabel
        )
        
        addSubviews(
            handleView,
            deleteAccountNoticeStackView,
            cancelButton,
            deleteAccountButton
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
        
        deleteAccountNoticeStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(deleteAccountNoticeStackView.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:))
        )
        handleView.isUserInteractionEnabled = true
        handleView.addGestureRecognizer(panGesture)
        
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonDidTap),
            for: .touchUpInside
        )
        
        deleteAccountButton.addTarget(
            self,
            action: #selector(deleteAccountButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                self.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended, .cancelled:
            if translation.y > 100 {
                onRequestDismiss?()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = .identity
                })
            }
        default:
            break
        }
    }
    
    @objc private func cancelButtonDidTap() {
        onRequestDismiss?()
    }
    @objc private func deleteAccountButtonDidTap() {
        onRequestDeleteAccount?()
    }
}
