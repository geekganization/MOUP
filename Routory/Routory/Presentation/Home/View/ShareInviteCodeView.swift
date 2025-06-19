//
//  ShareInviteCodeView.swift
//  Routory
//
//  Created by shinyoungkim on 6/19/25.
//

import UIKit
import Then
import SnapKit

final class ShareInviteCodeView: UIView {
    
    // MARK: - Properties
    
    var onDismiss: (() -> Void)?
    var didTapCopyInviteCodeBtn: (() -> Void)?
    
    // MARK: - UI Components
    
    private let handleView = UIView().then {
        $0.backgroundColor = .gray400
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "초대 코드"
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
    
    private let inviteCodeLabel = UILabel().then {
        $0.font = .headBold(24)
        $0.textColor = .black
    }
    
    private let copyInviteCodeButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "초대 코드 복사하기"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .primary500
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSemibold(14)
            return outgoing
        }

        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var copyInviteCodeButtonView: UIButton { copyInviteCodeButton }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(inviteCode: String) {
        inviteCodeLabel.text = inviteCode
    }
}

private extension ShareInviteCodeView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        titleView.addSubviews(
            handleView,
            titleLabel,
            seperatorView
        )
        
        addSubviews(
            titleView,
            inviteCodeLabel,
            copyInviteCodeButton
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
        
        inviteCodeLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        copyInviteCodeButton.snp.makeConstraints {
            $0.height.equalTo(45)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(34)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:))
        )
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(panGesture)
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
                onDismiss?()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = .identity
                })
            }
        default:
            break
        }
    }
    
}
