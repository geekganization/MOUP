//
//  ShiftRegistrationContentView.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit
import Then

final class ShiftRegistrationContentView: UIView {

    // MARK: - Subviews

    var isRead: Bool
    let simpleRowView: WorkPlaceSelectionView
    let workerSelectionView: WorkerSelectionView
    let routineView: RoutineView
    let workDateView: WorkDateView
    let workTimeView: WorkTimeView
    let memoBoxView: MemoBoxView
    let registerButton = UIButton(type: .system)
    let registerBtnTitle: String

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }

    // MARK: - Initializer

    init(
        isRead: Bool,
        workPlaceTitle: String,
        workerTitle: String,
        routineTitle: String,
        dateValue: String,
        repeatValue: String,
        startTime: String,
        endTime: String,
        restTime: String,
        memoPlaceholder: String,
        registerBtnTitle: String
    ) {
        self.isRead = isRead
        self.simpleRowView = WorkPlaceSelectionView(title: workPlaceTitle)
        self.workerSelectionView = WorkerSelectionView(title: workerTitle)
        self.routineView = RoutineView(title: routineTitle)
        self.workDateView = WorkDateView(dateValue: dateValue, repeatValue: repeatValue)
        self.workTimeView = WorkTimeView(startTime: startTime, endTime: endTime, restTime: restTime)
        self.memoBoxView = MemoBoxView(placeholder: memoPlaceholder)
        self.registerBtnTitle = registerBtnTitle
        
        super.init(frame: .zero)
        setupUI()
        layout()
        setReadMode(isRead)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(stackView)
        [
            simpleRowView,
            workerSelectionView,
            workDateView,
            workTimeView,
            routineView,
            memoBoxView,
            registerButton
        ].forEach { stackView.addArrangedSubview($0) }

        registerButton.setTitle(registerBtnTitle, for: .normal)
        registerButton.setTitleColor(.primary50, for: .normal)
        registerButton.backgroundColor = .primary500
        registerButton.titleLabel?.font = .buttonSemibold(18)
        registerButton.layer.cornerRadius = 8
        registerButton.isEnabled = true
        registerButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }

    private func layout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ShiftRegistrationContentView {
    func setReadMode(_ isRead: Bool) {
        self.isRead = isRead
        
        simpleRowView.isUserInteractionEnabled = !isRead
        workerSelectionView.isUserInteractionEnabled = !isRead
        routineView.isUserInteractionEnabled = !isRead
        workDateView.isUserInteractionEnabled = !isRead
        workTimeView.isUserInteractionEnabled = !isRead
        memoBoxView.isUserInteractionEnabled = !isRead
        registerButton.isHidden = isRead

        if isRead {
            simpleRowView.setChevronHidden()
            workerSelectionView.setChevronHidden()
            routineView.setChevronHidden()
            workDateView.setIsRead()
            workTimeView.setIsRead()
        } else {
            simpleRowView.setChevronVisible()
            workerSelectionView.setChevronVisible()
            routineView.setChevronVisible()
            workDateView.setIsEditable()
            workTimeView.setIsEditable()
        }
    }
}
