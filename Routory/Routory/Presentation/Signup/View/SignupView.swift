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
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .white
        addSubviews(titleLabel, buttonHStack, startButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(153)
            $0.centerX.equalToSuperview()
        }
        
        buttonHStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
            $0.centerX.equalToSuperview().inset(16)
        }
        startButton.snp.makeConstraints {
            $0.top.equalTo(buttonHStack.snp.bottom).offset(225)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
    }
    
    var onRoleConfirmed: ((String) -> Void)?
    
    private func setupActions() {
        ownerCardButton.addTarget(self, action: #selector(ownerTapped), for: .touchUpInside)
        workerCardButton.addTarget(self, action: #selector(workerTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action
    @objc private func ownerTapped() {
        ownerCardButton.isSelected = true
        workerCardButton.isSelected = false
        updateStartButtonState()
        print("사장님 버튼 클릭")
        // TODO: 선택 값 전달 등 추가 동작
    }
    @objc private func workerTapped() {
        ownerCardButton.isSelected = false
        workerCardButton.isSelected = true
        updateStartButtonState()
        print("알바생 버튼 클릭")
        // TODO: 선택 값 전달 등 추가 동작
    }
    
    //시작하기 버튼 상태 갱신 함수
    private func updateStartButtonState() {
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
    
    @objc private func startButtonTapped() {
        print("시작하기 버튼 클릭")
        
        // 선택된 역할 가져오기
        let role: String?
        if ownerCardButton.isSelected {
            role = "사장님"
        } else if workerCardButton.isSelected {
            role = "알바생"
        } else {
            role = nil
        }
        
        guard let selectedRole = role else { return }
        showCustomDialog(role: selectedRole)
    }
    
    // MARK: - Custom Dialog 연결
    private func showCustomDialog(role: String) {
        let dialog = CustomDialogView()
        dialog.getTitleLabel.text = "\(role)이신가요?"
        dialog.onNo = { [weak dialog] in
            dialog?.removeFromSuperview()
        }
        dialog.onYes = { [weak self, weak dialog] in
            dialog?.removeFromSuperview()
            // 역할 확정 콜백 실행 (뷰컨에 전달)
            self?.onRoleConfirmed?(role)
        }
        // 이 뷰에 오버레이로 붙임
        self.addSubview(dialog)
        dialog.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

