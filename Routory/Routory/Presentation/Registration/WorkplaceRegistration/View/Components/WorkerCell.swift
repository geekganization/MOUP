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
        colorView.backgroundColor = .lightGray // fallback 색상

        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .label

        contentView.addSubview(colorView)
        contentView.addSubview(nameLabel)

        accessoryType = .disclosureIndicator

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

    func configure(with info: WorkerDetailInfo) {
        nameLabel.text = info.detail.workerName
        colorView.backgroundColor = UIColor(hexString: info.detail.color) ?? .lightGray
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        guard hex.count == 6, let intCode = Int(hex, radix: 16) else {
            return nil
        }

        let r = CGFloat((intCode >> 16) & 0xFF) / 255.0
        let g = CGFloat((intCode >> 8) & 0xFF) / 255.0
        let b = CGFloat(intCode & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
