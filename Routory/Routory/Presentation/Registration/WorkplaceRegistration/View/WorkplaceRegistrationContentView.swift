//
//  WorkplaceRegistrationContentView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class WorkplaceRegistrationContentView: UIView {

    // MARK: - Subviews

    let workplaceInfoView: WorkplaceInfoView
    let salaryInfoView = SalaryInfoView()
    let workConditionView = WorkConditionView()
    let labelView = LabelView()
    let registerButton = UIButton(type: .system)

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }

    // MARK: - Initializer

    init(workplaceTitle: String) {
        self.workplaceInfoView = WorkplaceInfoView(title: workplaceTitle)
        super.init(frame: .zero)
        setupUI()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white

        [workplaceInfoView, salaryInfoView, workConditionView, labelView, registerButton]
            .forEach { stackView.addArrangedSubview($0) }

        registerButton.setTitle("등록하기", for: .normal)
        registerButton.setTitleColor(.primary50, for: .normal)
        registerButton.backgroundColor = .primary500
        registerButton.titleLabel?.font = .buttonSemibold(18)
        registerButton.layer.cornerRadius = 8
        registerButton.isEnabled = true
        registerButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        addSubview(stackView)
    }

    // MARK: - Layout

    private func layout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
