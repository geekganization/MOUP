//
//  TodaysRoutineCell.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import UIKit

class TodaysRoutineCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "TodaysRoutineCell"

    // MARK: - UI Components
    private let workplaceNameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let routineAmountLabel = UILabel().then {
        $0.font = .fieldsRegular(16)
        $0.textColor = .gray700
    }

    private let rightArrowButton = UIImageView().then {
        $0.image = .chevronRight
        $0.tintColor = .gray700
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
    func update(with todaysRoutine: DummyTodaysRoutine) {
        workplaceNameLabel.text = todaysRoutine.workplaceName
        routineAmountLabel.text = "+ \(todaysRoutine.routines.count)"
    }
}

private extension TodaysRoutineCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        contentView.addSubviews(workplaceNameLabel, routineAmountLabel, rightArrowButton)
    }

    func setStyles() {
        contentView.backgroundColor = .primaryBackground
    }

    func setConstraints() {
        workplaceNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        rightArrowButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(13)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }

        routineAmountLabel.snp.makeConstraints {
            $0.trailing.equalTo(rightArrowButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
}
