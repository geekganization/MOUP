//
//  WorkerCell.swift
//  Routory
//
//  Created by tlswo on 6/24/25.
//

import UIKit

final class WorkerCell: UITableViewCell {
    private let colorView = UIView()
    private let nameLabel = UILabel()
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.chevronRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        colorView.layer.cornerRadius = 6
        colorView.clipsToBounds = true
        colorView.backgroundColor = .lightGray

        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .label

        accessoryType = .none
        setupAccessoryView()

        contentView.addSubview(colorView)
        contentView.addSubview(nameLabel)

        colorView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 12),
            colorView.heightAnchor.constraint(equalToConstant: 12),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -32)
        ])
    }

    private func setupAccessoryView() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        chevronImageView.frame = container.bounds
        container.addSubview(chevronImageView)
        accessoryView = container
    }

    func configure(with info: WorkerDetailInfo) {
        nameLabel.text = info.detail.workerName
        print("info.detail.color: \(info.detail.color)")
        colorView.backgroundColor = LabelColorString(rawValue: info.detail.color)?.labelColor ?? LabelColorString._default.labelColor
    }
}
