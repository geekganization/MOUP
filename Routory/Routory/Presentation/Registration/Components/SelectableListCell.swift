//
//  SelectableListCell.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit

final class SelectableListCell: UITableViewCell {

    private let container = UIView()
    private let nameLabel = UILabel()
    private let checkIcon = UIImageView()

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

        nameLabel.font = .bodyMedium(16)
        nameLabel.textColor = .gray900

        checkIcon.setContentHuggingPriority(.required, for: .horizontal)
        checkIcon.contentMode = .scaleAspectFit

        contentView.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(checkIcon)

        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(checkIcon.snp.leading).offset(-8)
        }

        checkIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }

    func configure(icon: UIImage?, text: String, selected: Bool) {
        nameLabel.text = text

        checkIcon.image = UIImage(named: selected ? "RadioSelected" : "RadioUnselected")

        container.layer.borderColor = selected ? UIColor.primary500.cgColor : UIColor.systemGray4.cgColor
        container.backgroundColor = selected ? UIColor.primary500.withAlphaComponent(0.1) : .white
        nameLabel.textColor = selected ? .primary500 : .gray900
    }
}
