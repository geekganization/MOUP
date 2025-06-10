//
//  WorkplaceCell.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkplaceCell: UITableViewCell {

    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }

    private let checkIcon = UIImageView(image: UIImage(systemName: "checkmark")).then {
        $0.tintColor = .systemOrange
        $0.isHidden = true
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let container = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    func configure(with workplace: Workplace, selected: Bool) {
        nameLabel.text = workplace.workplacesName

        checkIcon.isHidden = !selected

        container.layer.borderColor = selected ? UIColor.systemOrange.cgColor : UIColor.systemGray4.cgColor
        container.backgroundColor = selected ? UIColor.systemOrange.withAlphaComponent(0.1) : .white
        nameLabel.textColor = selected ? .systemOrange : .label
    }
}
