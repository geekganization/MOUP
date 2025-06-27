//
//  SignupView.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class SignupView: UIView {

    // MARK: - Properties

    var onRoleConfirmed: ((String) -> Void)?

    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.text = "어떤 역할로 시작하시겠어요?"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }

    private let ownerCardButton = CardButton(
        image: UIImage(named: "Owner"),
        title: "사장님"
    )
    private let workerCardButton = CardButton(
        image: UIImage(named: "Alba"),
        title: "알바생"
    )

    private lazy var buttonHStack = UIStackView(arrangedSubviews: [ownerCardButton, workerCardButton]).then {
        $0.axis = .horizontal
        $0.spacing = 19
        $0.alignment = .top
        $0.distribution = .fillEqually
    }

    private let startButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.gray500, for: .normal)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .gray300
        $0.isEnabled = false
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Actions

    @objc
    private func ownerTapped() {
        // 사장님 역할 비활성화 코드
//        showOwnerWIPDialog(title: "조금만 기다려 주세요!",
//                           description: "사장님 기능은 다음 업데이트때 제공될 예정입니다!")
        
        ownerCardButton.isSelected = true
        workerCardButton.isSelected = false
        updateStartButtonState()
    }

    @objc
    private func workerTapped() {
        ownerCardButton.isSelected = false
        workerCardButton.isSelected = true
        updateStartButtonState()
    }

    @objc
    private func startButtonTapped() {
        let role: String?
        if ownerCardButton.isSelected {
            role = "사장님"
        } else if workerCardButton.isSelected {
            role = "알바생"
        } else {
            role = nil
        }
        guard let selectedRole = role else { return }
        showCustomDialog(title: "\(selectedRole)이신가요?",
                         description: "역할 선택은 한 번만 가능합니다.\n선택 후에는 변경이 불가하니 신중하게 선택해 주세요!",
                         role: selectedRole)
    }
}

// MARK: - UI Setup

private extension SignupView {
    func configure() {
        backgroundColor = .white
        setHierarchy()
        setConstraints()
        setActions()
    }

    func setHierarchy() {
        addSubviews(titleLabel, buttonHStack, startButton)
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(159)
            $0.centerX.equalToSuperview()
        }
        buttonHStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
            $0.centerX.equalToSuperview().inset(16)
        }
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(46)
            $0.height.equalTo(45)
        }
    }

    func setActions() {
        ownerCardButton.addTarget(self, action: #selector(ownerTapped), for: .touchUpInside)
        workerCardButton.addTarget(self, action: #selector(workerTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }

    func updateStartButtonState() {
        if ownerCardButton.isSelected || workerCardButton.isSelected {
            startButton.isEnabled = true
            startButton.backgroundColor = .primary500
            startButton.setTitleColor(.white, for: .normal)
        } else {
            startButton.isEnabled = false
            startButton.backgroundColor = .gray300
            startButton.setTitleColor(.gray500, for: .normal)
        }
    }
    
    func showOwnerWIPDialog(title: String, description: String) {
        let dialog = CustomDialogView()
        dialog.getTitleLabel.text = title
        dialog.getDescLabel.text = description
        dialog.getNoButton.isHidden = true
        dialog.getYesButton.setTitle("확인", for: .normal)
        dialog.onYes = { dialog.removeFromSuperview() }
        self.addSubview(dialog)
        dialog.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func showCustomDialog(title: String, description: String, role: String) {
        let dialog = CustomDialogView()
        dialog.getTitleLabel.text = title
        dialog.getDescLabel.text = description
        dialog.onNo = { [weak dialog] in
            dialog?.removeFromSuperview()
        }
        dialog.onYes = { [weak self, weak dialog] in
            dialog?.removeFromSuperview()
            self?.onRoleConfirmed?(role)
        }
        self.addSubview(dialog)
        dialog.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
