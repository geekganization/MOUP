//
//  WorkShiftRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkShiftRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView().then {
        $0.keyboardDismissMode = .interactive
    }

    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .fill
    }

    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("등록하기", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.backgroundColor = UIColor.systemGray5
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
    }

    private func setupUI() {
        title = "근무 등록"
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(SimpleRowView(title: "근무지 선택 *"))
        contentStack.addArrangedSubview(FieldBoxView(title: "근무 날짜 *", rows: [
            ("날짜", "2025.07.07", nil),
            ("반복", nil, nil)
        ]))
        contentStack.addArrangedSubview(FieldBoxView(title: "근무시간 *", rows: [
            ("출근", nil, nil),
            ("퇴근", nil, nil),
            ("휴게", nil, nil)
        ]))
        contentStack.addArrangedSubview(FieldBoxView(title: "루틴", rows: [
            ("루틴 추가", nil, nil)
        ]))
        contentStack.addArrangedSubview(FieldBoxView(title: "라벨", rows: [
            ("빨간색", nil, true)
        ]))
        contentStack.addArrangedSubview(MemoBoxView())
        contentStack.addArrangedSubview(registerButton)
    }

    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }

        registerButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
}
