//
//  CommonRoutineCell.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import UIKit

class CommonRoutineCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CommonRoutineCell"

    // MARK: - UI Components
    private let routineTitleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let routineAlarmLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let chevronIcon = UIImageView().then {
        $0.image = .chevronRight
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
    func update(with routine: Routine) {
        routineTitleLabel.text = routine.routineName
        routineAlarmLabel.text = routine.alarmTime
    }
}

private extension CommonRoutineCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        contentView.addSubviews(
            routineTitleLabel,
            routineAlarmLabel,
            chevronIcon
        )
    }

    func setStyles() {
        contentView.backgroundColor = .primaryBackground
        self.selectionStyle = .none
    }

    func setConstraints() {
        routineTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        chevronIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
        routineAlarmLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronIcon.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
}
