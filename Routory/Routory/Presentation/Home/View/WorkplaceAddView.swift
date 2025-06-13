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
    
    // MARK: - Properties
    
    var onDismiss: (() -> Void)?
    
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
    
    private lazy var inviteCodeButton = makeFilledButton(
        title: "초대 코드 입력하기",
        image: UIImage.mail
    )

    private lazy var manualInputButton = makeFilledButton(
        title: "직접 입력하기",
        image: UIImage.plus
    )
    
    // MARK: - Getter
    
    var inviteCodeButtonView: UIButton { inviteCodeButton }
    var manualInputButtonView: UIButton { manualInputButton }
    
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
            inviteCodeButton,
            manualInputButton
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
        
        inviteCodeButton.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        manualInputButton.snp.makeConstraints {
            $0.top.equalTo(inviteCodeButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
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
    
    func makeFilledButton(title: String, image: UIImage) -> UIButton {
        let button = UIButton().then {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = image
            config.imagePadding = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            config.baseForegroundColor = .gray900
            config.baseBackgroundColor = .white
            config.cornerStyle = .fixed
            config.imagePlacement = .leading
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .bodyMedium(14)
                return outgoing
            }

            $0.configuration = config
            $0.contentHorizontalAlignment = .leading
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.layer.borderColor = UIColor.gray400.cgColor
            $0.layer.borderWidth = 1
        }
        return button
    }
}
