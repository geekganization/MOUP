//
//  DeleteAlertViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/25/25.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class DeleteAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    private let alertTitle: String
    private let alertMessage: String
    var onDeleteConfirmed: (() -> Void)?
    private let disposeBag = DisposeBag()
    private let deleteButtonTitle: String
    
    // MARK: - UI Components
    
    private lazy var titleLabel = UILabel().then {
        $0.text = alertTitle
        $0.font = .headBold(18)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
    }
    
    private lazy var messageLabel = UILabel().then {
        $0.text = alertMessage
        $0.font = .bodyMedium(14)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.numberOfLines = 0
    }
    
    private lazy var cancelButton = makeFilledButton(
        title: "아니요",
        foregroundColor: .gray600,
        backgroundColor: .gray200
    )

    private lazy var deleteButton = makeFilledButton(
        title: deleteButtonTitle
    )
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    init(
        alertTitle: String = "정말 삭제하시겠어요?",
        alertMessage: String = "삭제된 정보는 되돌릴 수 없습니다.",
        deleteButtonTitle: String = "삭제하기"
    ) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.deleteButtonTitle = deleteButtonTitle
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension DeleteAlertViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubview(contentView)
        
        contentView.addSubviews(
            titleLabel,
            messageLabel,
            buttonStackView
        )
        
        buttonStackView.addArrangedSubviews(
            cancelButton,
            deleteButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(210)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().offset(16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        cancelButton.rx.tap
            .bind { [weak self] in
                print("삭제 취소")
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind { [weak self] in
                print("삭제 확정")
                self?.onDeleteConfirmed?()
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        backgroundDidTapDismissAction()
    }
}

private extension DeleteAlertViewController {
    func makeFilledButton(
        title: String,
        font: UIFont = UIFont.buttonSemibold(18),
        foregroundColor: UIColor = .white,
        backgroundColor: UIColor = .primary500,
        cornerRadius: CGFloat = 12
    ) -> UIButton {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = foregroundColor
        config.baseBackgroundColor = backgroundColor
        config.cornerStyle = .fixed
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }

        button.configuration = config
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true

        return button
    }
    
    func backgroundDidTapDismissAction() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundDidTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundDidTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if !contentView.frame.contains(location) {
            print("백그라운드 터치")
            dismiss(animated: true)
        }
    }
}
