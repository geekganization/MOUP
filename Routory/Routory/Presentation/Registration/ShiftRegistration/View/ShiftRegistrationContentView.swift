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

    let simpleRowView = WorkPlaceSelectionView(title: "근무지 수정")
    let workerSelectionView = WorkerSelectionView(title: "인원 선택")
    let routineView = RoutineView(title: "루틴 추가")
    let workDateView = WorkDateView(dateValue: "2025.07.07", repeatValue: "없음")
    let workTimeView = WorkTimeView(startTime: "09:00", endTime: "18:00", restTime: "1시간")
    let memoBoxView = MemoBoxView(placeholder: "내용을 입력하세요.")
    let registerButton = UIButton(type: .system)

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)
        [simpleRowView, workerSelectionView, workDateView, workTimeView, routineView, memoBoxView, registerButton]
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
    }

    private func layout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
