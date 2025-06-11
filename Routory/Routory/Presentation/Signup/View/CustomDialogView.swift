//
//  CustomDialogView.swift
//  Routory
//
//  Created by 양원식 on 6/11/25.
//

import UIKit
import SnapKit
import Then

final class CustomDialogView: UIView {

    // MARK: - Properties

    var onYes: (() -> Void)?
    var onNo: (() -> Void)?
    var getTitleLabel: UILabel { titleLabel }

    // MARK: - UI Components

    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    private let dialogBox = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.text = "알바생이신가요?"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    private let descLabel = UILabel().then {
        $0.text = "역할 선택은 한 번만 가능합니다.\n선택 후에는 변경이 불가하니 신중하게 선택해 주세요!"
        $0.font = .bodyMedium(14)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    private let noButton = UIButton().then {
        $0.setTitle("아니요", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.gray600, for: .normal)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 8
    }
    private let yesButton = UIButton().then {
        $0.setTitle("네", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 8
    }
    private lazy var buttonStack = UIStackView(arrangedSubviews: [noButton, yesButton]).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    // MARK: - Init

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
    private func noTapped() { onNo?() }
    @objc
    private func yesTapped() { onYes?() }
}

// MARK: - UI Setup

private extension CustomDialogView {
    func configure() {
        setHierarchy()
        setConstraints()
        setActions()
    }
    func setHierarchy() {
        addSubviews(dimmedView, dialogBox)
        dialogBox.addSubviews(titleLabel, descLabel, buttonStack)
    }
    func setConstraints() {
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        dialogBox.snp.makeConstraints {
            $0.centerY.equalToSuperview().inset(301)
            $0.centerX.equalToSuperview().inset(24)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(descLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    func setActions() {
        noButton.addTarget(self, action: #selector(noTapped), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
    }
}
