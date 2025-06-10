//
//  RoutineView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class RoutineView: UIView, FieldRowViewDelegate {

    private let addRow = FieldRowView(title: "루틴 추가", value: nil)

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "루틴"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [addRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        print("루틴 추가 클릭")
    }
}
