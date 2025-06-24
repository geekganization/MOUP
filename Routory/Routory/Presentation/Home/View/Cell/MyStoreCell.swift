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
        config.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        $0.configuration = config
    }

    private let daysUntilPaydayLabel = UILabel().then {
        $0.textColor = .gray700
        $0.font = .bodyMedium(12)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }

    private let totalLaborCostLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    @available(*, unavailable, message: "storyboard is not been implemented.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()

        storeNameLabel.text = nil
        daysUntilPaydayLabel.text = nil
        totalLaborCostLabel.text = nil
        menuButton.menu = nil
    }

    // MARK: - Public Methods
    func update(with storeInfo: StoreCellInfo, menuActions: [UIAction]) {
        storeNameLabel.text = storeInfo.storeName
        daysUntilPaydayLabel.text = "급여일까지 D-\(storeInfo.daysUntilPayday)"
        totalLaborCostLabel.text = "\(storeInfo.totalLaborCost.withComma)원"

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
            totalLaborCostLabel
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
            $0.bottom.equalToSuperview()
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

        totalLaborCostLabel.snp.makeConstraints {
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
