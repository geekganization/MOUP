//
//  MyStoreCell.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MyStoreCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "MyStoreCell"
    fileprivate var disposeBag = DisposeBag()

    // MARK: - UI Components
    private let containerView = CardView()

    private let headerView = UIView().then {
        $0.backgroundColor = .clear
    }

    private let storeNameLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }

    private let officialChip = ChipLabel(title: "연동", color: .primary100, titleColor: .primary600)

    fileprivate let menuButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .ellipsis.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        config.contentInsets = .init(top: 20, leading: 12, bottom: 19.7, trailing: 12)
        $0.configuration = config
    }

    private let daysUntilPaydayLabel = UILabel().then {
        $0.textColor = .gray700
        $0.font = .bodyMedium(12)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }

    private let totalEarnedLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable, message: "storyboard is not been implemented.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(menuActions: [UIAction]) {
        let storeName: String = "맥도날드 강북 수유점"
        let daysUntilPayday: Int = 18
        let totalEarned: Int = 252000

        storeNameLabel.text = storeName
        daysUntilPaydayLabel.text = "급여일까지 D-\(daysUntilPayday)"
        totalEarnedLabel.text = "\(totalEarned.withComma)원"

        setupButtonMenu(with: menuActions)
    }
}

private extension MyStoreCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        contentView.addSubviews(containerView)

        containerView.addSubviews(
            headerView
        )
        headerView.addSubviews(
            storeNameLabel,
            officialChip,
            menuButton,
            daysUntilPaydayLabel,
            totalEarnedLabel
        )
    }

    func setStyles() {
        contentView.backgroundColor = .systemBackground
    }

    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8).priority(.high)
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
        }

        storeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }

        officialChip.snp.makeConstraints {
            $0.leading.equalTo(storeNameLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(storeNameLabel)
        }

        daysUntilPaydayLabel.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom)
            $0.leading.equalTo(storeNameLabel.snp.leading)
        }

        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(4)
            $0.size.equalTo(44)
        }

        totalEarnedLabel.snp.makeConstraints {
            $0.top.equalTo(daysUntilPaydayLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }
    }

    func setupButtonMenu(with actions: [UIAction]) {
        let menu = UIMenu(children: actions)

        self.menuButton.menu = menu
        self.menuButton.showsMenuAsPrimaryAction = true
    }
}
