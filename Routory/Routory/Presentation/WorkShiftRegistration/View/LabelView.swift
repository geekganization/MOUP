//
//  LabelView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class LabelView: UIView, FieldRowViewDelegate {

    private let redLabelRow = FieldRowView(title: "빨간색", value: nil, showDot: true)

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        redLabelRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "라벨"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [redLabelRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        print("라벨 클릭")
    }
}
