//
//  TimePickerViewController.swift
//  Routory
//
//  Created by tlswo on 6/30/25.
//

import UIKit
import SnapKit
import Then

final class TimePickerViewController: UIViewController {

    private let picker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
    }

    var onConfirm: ((Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let confirmButton = UIButton(type: .system).then {
            $0.setTitle("확인", for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
        }
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [picker, confirmButton]).then {
            $0.axis = .vertical
            $0.spacing = 0
            $0.alignment = .fill
            $0.distribution = .fill
        }

        view.addSubview(stack)

        stack.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }

    func setInitialDate(_ date: Date) {
        picker.date = date
    }

    @objc private func confirmTapped() {
        onConfirm?(picker.date)
        dismiss(animated: true)
    }
}
