//
//  WorkplaceCell.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - WorkplaceCell

final class WorkplaceCell: UITableViewCell {

    // MARK: - UI Components

    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
    }

    private let checkIcon = UIImageView(image: UIImage(systemName: "checkmark")).then {
        $0.tintColor = .primary500
        $0.isHidden = true
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let container = UIView()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        container.layer.cornerRadius = 10
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.clipsToBounds = true

        contentView.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(checkIcon)

        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualTo(checkIcon.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        checkIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }

    // MARK: - Configuration

    func configure(with workplace: Workplace, selected: Bool) {
        nameLabel.text = workplace.workplacesName

        checkIcon.isHidden = !selected

        container.layer.borderColor = selected ? UIColor.primary500.cgColor : UIColor.systemGray4.cgColor
        container.backgroundColor = selected ? UIColor.primary500.withAlphaComponent(0.1) : .white
        nameLabel.textColor = selected ? .primary500 : .label
    }
}
