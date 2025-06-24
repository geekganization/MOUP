//
//  ApprovalNotificationCell.swift
//  Routory
//
//  Created by 송규섭 on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

class ApprovalNotificationCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "ApprovalNotificationCell"

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

    private let twoButtonStackView = UIStackView().then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }

    fileprivate let rejectButton = UIButton().then {
        $0.setTitle("거절", for: .normal)
        $0.setTitleColor(.gray600, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(14)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
    }

    fileprivate let approveButton = UIButton().then {
        $0.setTitle("승인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(14)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
    }

    private let singleButton = UIButton().then { // 승인, 거절 상태 시 단일 버튼
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.gray500, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(14)
        $0.backgroundColor = .gray300
        $0.layer.cornerRadius = 12
        $0.isUserInteractionEnabled = false
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
    func update(with notification: DummyNotification, type: ApprovalStatus) {
        titleLabel.text = notification.title
        contentLabel.text = notification.content
        timeLabel.text = notification.time
        contentView.backgroundColor = notification.isRead ? .white : .primary50
        circleView.backgroundColor = notification.isRead ? .gray300 : .primary500

        applyStatus(by: type)
    }

    func applyStatus(by status: ApprovalStatus) {
        switch status {
        case .pending:
            setPendingStatus()
        case .approved:
            setApprovedStatus()
        case .rejected:
            setRejectedStatus()
        }
    }
}

private extension ApprovalNotificationCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        contentView.addSubviews(
            circleView, titleLabel, contentLabel, timeLabel, twoButtonStackView, singleButton
        )
        circleView.addSubviews(bellImageView)
        twoButtonStackView.addArrangedSubviews(rejectButton, approveButton)
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
        }

        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }

        twoButtonStackView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(4)
            $0.directionalHorizontalEdges.equalTo(contentLabel)
            $0.height.equalTo(41)
            $0.bottom.equalToSuperview().inset(12)
        }

        singleButton.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(4)
            $0.directionalHorizontalEdges.equalTo(contentLabel)
            $0.height.equalTo(41)
            $0.bottom.equalToSuperview().inset(12)
        }
    }

    // MARK: - Applying approvalStatus

    func setPendingStatus() {
        twoButtonStackView.isHidden = false
        singleButton.isHidden = true // TODO: - 단, 두 버튼 중 승인 / 거절 상태 api 처리가 완료될 시 처리
    }

    func setApprovedStatus() {
        twoButtonStackView.isHidden = true
        singleButton.isHidden = false
        singleButton.setTitle("승인", for: .normal)
        singleButton.backgroundColor = .gray300
        singleButton.setTitleColor(.gray500, for: .normal)
    }

    func setRejectedStatus() {
        twoButtonStackView.isHidden = true
        singleButton.isHidden = false
        singleButton.setTitle("거절", for: .normal)
        singleButton.backgroundColor = .gray300
        singleButton.setTitleColor(.gray500, for: .normal)
    }
}

extension Reactive where Base: ApprovalNotificationCell {
    var approveButtonTapped: ControlEvent<Void> {
        return base.approveButton.rx.tap
    }

    var rejectButtonTapped: ControlEvent<Void> {
        return base.rejectButton.rx.tap
    }
}
