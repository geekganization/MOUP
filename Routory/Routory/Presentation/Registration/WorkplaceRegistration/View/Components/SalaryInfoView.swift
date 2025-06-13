//
//  SalaryInfoView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit

final class SalaryInfoView: UIView {

    private let typeRow = ValueRowView(title: "급여 유형", value: "매월")
    private let calcRow = ValueRowView(title: "급여 계산", value: "고정")
    private let fixedSalaryRow = ValueRowView(title: "고정급", value: "1,000,000원")
    private let payDateRow = FieldRowView(title: "급여일", value: "25일")

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let titleLabel = UILabel().then {
            $0.text = "급여"
            $0.font = .headBold(18)
        }

        let box = makeBoxedStackView(with: [typeRow, calcRow, fixedSalaryRow, payDateRow])

        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
