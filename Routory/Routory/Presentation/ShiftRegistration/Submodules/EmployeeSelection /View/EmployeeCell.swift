//
//  EmployeeCell.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit
import Then

// MARK: - EmployeeCell

final class EmployeeCell: UITableViewCell {

    // MARK: - Callback

    var onTapCheckbox: (() -> Void)?

    // MARK: - UI Components

    private let checkbox = UIImageView().then {
        $0.tintColor = .primary500
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }

    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    private func setup() {
        selectionStyle = .none

        contentView.addSubview(checkbox)
        contentView.addSubview(nameLabel)

        checkbox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(checkbox.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        let checkTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkbox.addGestureRecognizer(checkTap)
    }

    // MARK: - Configure

    func configure(with employee: Employee) {
        nameLabel.text = employee.name
        let imageName = employee.isSelected ? "CheckboxSelected" : "CheckboxUnselected"
        checkbox.image = UIImage(named: imageName)
    }

    // MARK: - Action

    @objc private func didTapCheckbox() {
        onTapCheckbox?()
    }
}
