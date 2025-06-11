//
//  DayCell.swift
//  Routory
//
//  Created by tlswo on 6/11/25.
//

import UIKit
import SnapKit
import Then

// MARK: - DayCell

final class DayCell: UITableViewCell {

    // MARK: - Identifier

    static let identifier = "DayCell"

    // MARK: - UI Components

    private let checkBoxImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private let dayLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
    }

    // MARK: - Configuration

    func configure(with day: String, isSelected: Bool) {
        dayLabel.text = day

        let imageName = isSelected ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        checkBoxImageView.image = image?.withTintColor(
            isSelected ? .primary500 : .systemGray3,
            renderingMode: .alwaysOriginal
        )

        setupViews()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(checkBoxImageView)
        contentView.addSubview(dayLabel)
    }

    private func setupConstraints() {
        checkBoxImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        dayLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBoxImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        checkBoxImageView.image = nil
        dayLabel.text = nil
    }
}
