//
//  WorkDateView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkDateView: UIView, FieldRowViewDelegate {

    private let dateRow = FieldRowView(title: "날짜", value: "2025.07.07")
    private let repeatRow = FieldRowView(title: "반복", value: nil)

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        dateRow.delegate = self
        repeatRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "근무 날짜"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [dateRow, repeatRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        if row === dateRow {
            print("날짜 클릭")
        } else if row === repeatRow {
            print("반복 클릭")
        }
    }
}
