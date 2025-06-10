//
//  FieldBoxView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class FieldBoxView: UIStackView {

    init(title: String, rows: [(String, String?, Bool?)]) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        setup(title: title, rows: rows)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String, rows: [(String, String?, Bool?)]) {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 0
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.clipsToBounds = true
        }

        for (index, row) in rows.enumerated() {
            let isLast = index == rows.count - 1
            box.addArrangedSubview(FieldRowView(title: row.0, value: row.1, showDot: row.2 ?? false, showSeparator: !isLast))
        }

        addArrangedSubview(titleLabel)
        addArrangedSubview(box)
    }
}
