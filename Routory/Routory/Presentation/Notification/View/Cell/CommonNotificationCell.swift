//
//  CommonNotificationCell.swift
//  Routory
//
//  Created by 송규섭 on 6/17/25.
//

import UIKit

class CommonNotificationCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CommonNotificationCell"

    // MARK: - UI Components
    private let circleView = UIView().then {
        $0.backgroundColor = .gray300
    }

    private let bellImageView = UIImageView().then {
        $0.image = .bellEmpty.withRenderingMode(.alwaysTemplate)
        $0.backgroundColor = .clear
        $0.tintColor = .white
    }

    private let titleLabel = UILabel().then {
        $0.text = "알림 제목"
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.numberOfLines = 1
        $0.textColor = .gray900
    }

    private let contentLabel = UILabel().then {
        $0.text = "알림\n내용"
        $0.font = .bodyMedium(14)
        $0.setLineSpacing(.bodyMedium)
        $0.numberOfLines = 2
        $0.textColor = .gray700
    }

    private let timeLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray400
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(with notification: DummyNotification) {
        titleLabel.text = notification.title
        contentLabel.text = notification.content
        timeLabel.text = notification.time
        contentView.backgroundColor = notification.isRead ? .white : .primary50
        circleView.backgroundColor = notification.isRead ? .gray300 : .primary500
    }
}

private extension CommonNotificationCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        contentView.addSubviews(
            circleView, titleLabel, contentLabel, timeLabel
        )

        circleView.addSubviews(bellImageView)
    }

    func setStyles() {
        contentView.backgroundColor = .primaryBackground
        self.selectionStyle = .none
        circleView.layer.cornerRadius = 16
    }

    func setConstraints() {
        circleView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }

        bellImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(bellImageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-8)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
