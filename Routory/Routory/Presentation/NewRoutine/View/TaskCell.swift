//
//  TaskCell.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class TaskCell: UITableViewCell {

    private let taskLabel = UILabel().then {
        $0.text = "할 일"
        $0.textColor = .systemGray
        $0.font = .systemFont(ofSize: 14)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(taskLabel)

        taskLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
        }
    }

    func configure(text: String) {
        taskLabel.text = text.isEmpty ? "할 일" : text
    }
}
