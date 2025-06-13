//
//  FirstSectionCellRowView.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import UIKit

final class HomeFirstSectionCellRowView: UIView {
    // MARK: - Properties

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "제목"
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
        $0.textAlignment = .left
    }

    private let timeLabel = UILabel().then {
        $0.text = "-"
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
        $0.textAlignment = .right
    }

    private let amountLabel = UILabel().then {
        $0.text = "-"
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
        $0.textAlignment = .right
    }

    private let bottomBorderLine = UIView()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(title: String, time: String?, amount: Int, isLabelBold: Bool = false, showTimeLabel: Bool = true, showBottomLine: Bool = false, useDarkBottomLine: Bool = false) {
        titleLabel.text = title.isEmpty ? "-" : title
        titleLabel.textAlignment = titleLabel.text == "-" ? .center : .left
        timeLabel.text = (time?.isEmpty ?? true) ? "-" : time // TODO: - timeFormatter 이용해 시간, 분 표시 필요
        timeLabel.textAlignment = timeLabel.text == "-" ? .center : .right
        amountLabel.text = amount == 0 ? "-" : "\(amount.withComma)원"
        amountLabel.textAlignment = amountLabel.text == "-" ? .center : .right
        [titleLabel, timeLabel, amountLabel].forEach { label in
            label.font = isLabelBold ? .headBold(12) : .bodyMedium(12)
        }
        timeLabel.isHidden = !showTimeLabel
        bottomBorderLine.isHidden = !showBottomLine
        bottomBorderLine.backgroundColor = useDarkBottomLine ? .gray700 : .gray300
    }
}

private extension HomeFirstSectionCellRowView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(titleLabel, timeLabel, amountLabel, bottomBorderLine)
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .systemBackground
    }

    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(3)
            $0.leading.centerY.equalToSuperview()
            $0.width.equalTo(51)
            $0.height.equalTo(18)
        }

        amountLabel.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(3)
            $0.trailing.centerY.equalToSuperview()
            $0.width.equalTo(77.5)
            $0.height.equalTo(18)
        }

        timeLabel.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(3)
            $0.trailing.equalTo(amountLabel.snp.leading).offset(-12)
            $0.centerY.equalTo(amountLabel.snp.centerY)
            $0.width.equalTo(77.5)
            $0.height.equalTo(18)
        }

        bottomBorderLine.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

