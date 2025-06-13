//
//  WorkplaceInfoView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit

final class WorkplaceInfoView: UIView {

    private let nameRow = ValueRowView(title: "이름", value: "세븐일레븐 동탄제일점")
    private let categoryRow = ValueRowView(title: "카테고리", value: "편의점")

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let titleLabel = UILabel().then {
            $0.text = "근무지"
            $0.font = .headBold(18)
        }

        let box = makeBoxedStackView(with: [nameRow, categoryRow])

        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
