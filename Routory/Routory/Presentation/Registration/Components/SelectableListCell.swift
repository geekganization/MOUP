//
//  SelectableListCell.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import Then
import SnapKit

final class SelectableListCell: UITableViewCell {

    private let container = UIView()
    private let categoryIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let nameLabel = UILabel()
    private let checkIcon = UIImageView()
    
    private var nameLabelLeadingWithIcon: Constraint?
    private var nameLabelLeadingWithoutIcon: Constraint?

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

        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.gray400.cgColor
        container.clipsToBounds = true

        nameLabel.font = .bodyMedium(16)
        nameLabel.textColor = .gray900

        checkIcon.setContentHuggingPriority(.required, for: .horizontal)
        checkIcon.contentMode = .scaleAspectFit

        contentView.addSubview(container)
        container.addSubviews(
            categoryIcon,
            nameLabel,
            checkIcon
        )

        container.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        categoryIcon.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            nameLabelLeadingWithIcon = $0.leading.equalTo(categoryIcon.snp.trailing).offset(12).constraint
            nameLabelLeadingWithoutIcon = $0.leading.equalToSuperview().offset(16).constraint
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(checkIcon.snp.leading).offset(-8)
        }

        checkIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }

    func configure(icon: String?, text: String, selected: Bool) {
        nameLabel.text = text

        checkIcon.image = UIImage(named: selected ? "RadioSelected" : "RadioUnselected")

        container.layer.borderColor = selected ? UIColor.primary500.cgColor : UIColor.gray400.cgColor
        container.layer.borderWidth = selected ? 2 : 1
        container.backgroundColor = selected ? UIColor.primary50 : .white
        if let icon = icon {
            let iconName = "\(icon)\(selected ? "Selected" : "Unselected")"
            categoryIcon.image = UIImage(named: iconName)
            categoryIcon.isHidden = false
            nameLabelLeadingWithIcon?.activate()
            nameLabelLeadingWithoutIcon?.deactivate()
        } else {
            categoryIcon.image = nil
            categoryIcon.isHidden = true
            nameLabelLeadingWithIcon?.deactivate()
            nameLabelLeadingWithoutIcon?.activate()
        }
        nameLabel.textColor = selected ? .primary600 : .gray900
    }
}
