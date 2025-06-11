//
//  RoutineCell.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - RoutineCell

final class RoutineCell: UITableViewCell {

    // MARK: - Callbacks

    var onTapCheckbox: (() -> Void)?
    var onTapChevron: (() -> Void)?

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

    private let timeLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let arrow = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.tintColor = .systemGray3
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }

    // MARK: - Initializers

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
        contentView.addSubview(timeLabel)
        contentView.addSubview(arrow)

        checkbox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(checkbox.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        arrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }

        timeLabel.snp.makeConstraints {
            $0.trailing.equalTo(arrow.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        // MARK: - Gesture Setup

        let checkTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkbox.addGestureRecognizer(checkTap)

        let chevronTap = UITapGestureRecognizer(target: self, action: #selector(didTapChevron))
        arrow.addGestureRecognizer(chevronTap)
    }

    // MARK: - Configuration

    func configure(with item: RoutineItem) {
        nameLabel.text = item.routine.routineName
        timeLabel.text = item.routine.alarmTime
        let imageName = item.isSelected ? "CheckboxSelected" : "CheckboxUnselected"
        checkbox.image = UIImage(named: imageName)
    }

    // MARK: - Actions

    @objc private func didTapCheckbox() {
        onTapCheckbox?()
    }

    @objc private func didTapChevron() {
        onTapChevron?()
    }
}
