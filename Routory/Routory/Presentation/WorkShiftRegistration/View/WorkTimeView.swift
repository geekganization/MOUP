//
//  WorkTimeView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkTimeView: UIView, FieldRowViewDelegate {

    private let startRow = FieldRowView(title: "출근", value: nil)
    private let endRow = FieldRowView(title: "퇴근", value: nil)
    private let restRow = FieldRowView(title: "휴게", value: nil)

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        [startRow, endRow, restRow].forEach { $0.delegate = self }

        let titleLabel = UILabel().then {
            $0.text = "근무시간"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [startRow, endRow, restRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        switch row {
        case startRow: print("출근 클릭")
        case endRow: print("퇴근 클릭")
        case restRow: print("휴게 클릭")
        default: break
        }
    }
}
