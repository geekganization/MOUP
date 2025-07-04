//
//  MyWorkSpaceCell.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MyWorkSpaceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "MyWorkSpaceCell"
    private var expandToggleTopToHeaderConstraint: Constraint?
    private var expandToggleTopToDetailConstraint: Constraint?
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

    private let totalEarnedLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    // 펼치기, 접기 토글 아이콘
    private let expandToggleImageView = UIImageView().then {
        $0.image = .chevronFolded
        $0.tintColor = .gray700
    }

    // 급여 상세 명세표 스택뷰
    private let detailStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.isHidden = true
    }

    // 급여 상세 요소들
    private let totalWorkRow = HomeFirstSectionCellRowView()
    private let insuranceDeductionRow = HomeFirstSectionCellRowView()
    private let employmentInsuranceRow = HomeFirstSectionCellRowView()
    private let healthInsuranceRow = HomeFirstSectionCellRowView()
    private let industrialAccidentRow = HomeFirstSectionCellRowView()
    private let nationalPensionRow = HomeFirstSectionCellRowView()
    private let incomeTaxRow = HomeFirstSectionCellRowView()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    @available(*, unavailable, message: "storyboard is not been implemented.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        detailStackView.isHidden = true
        expandToggleImageView.image = .chevronFolded
        expandToggleTopToDetailConstraint?.deactivate()
        expandToggleTopToHeaderConstraint?.activate()
        disposeBag = DisposeBag() // 이전 바인딩 해제
    }

    // MARK: - Public Methods
    func update(with workplaceInfo: WorkplaceCellInfo, isExpanded: Bool, menuActions: [UIAction]) {
        let isTemporary = workplaceInfo.id == "999999999"
        storeNameLabel.text = workplaceInfo.storeName
        officialChip.isHidden = !workplaceInfo.isOfficial
        daysUntilPaydayLabel.text = isTemporary ? "급여일까지의 D-day" : "급여일까지 D-\(workplaceInfo.daysUntilPayday)"
        setTotalEarnedLabel(amount: workplaceInfo.totalEarned.withComma, isTemporary: isTemporary)

        let totalInsurance = workplaceInfo.employmentInsurance + workplaceInfo.healthInsurance + workplaceInfo.industrialAccident + workplaceInfo.nationalPension


        totalWorkRow.update(title: "총 근무", time: workplaceInfo.totalWorkTime, amount: workplaceInfo.totalEarned, isLabelBold: true, showBottomLine: true, useDarkBottomLine: true)
        insuranceDeductionRow.update(title: "4대 보험", time: nil, amount: totalInsurance, isLabelBold: true, showTimeLabel: false)
        employmentInsuranceRow.update(title: "고용 보험", time: nil, amount: workplaceInfo.employmentInsurance, isLabelBold: false, showTimeLabel: false)
        healthInsuranceRow.update(title: "건강 보험", time: nil, amount: workplaceInfo.healthInsurance, isLabelBold: false, showTimeLabel: false)
        industrialAccidentRow.update(title: "산재 보험", time: nil, amount: workplaceInfo.industrialAccident, isLabelBold: false, showTimeLabel: false)
        nationalPensionRow.update(title: "국민 연금", time: nil, amount: workplaceInfo.nationalPension, isLabelBold: false, showTimeLabel: false)
        incomeTaxRow.update(title: "소득세", time: nil, amount: workplaceInfo.incomeTax, isLabelBold: true, showTimeLabel: false)

        toggleDetailView(isExpanded: isExpanded)
        menuButton.isHidden = isTemporary
        setupButtonMenu(with: menuActions)
    }
}

private extension MyWorkSpaceCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        contentView.addSubviews(containerView)

        containerView.addSubviews(
            headerView,
            detailStackView,
            expandToggleImageView
        )
        headerView.addSubviews(
            storeNameLabel,
            officialChip,
            menuButton,
            daysUntilPaydayLabel,
            totalEarnedLabel
        )
        detailStackView.addArrangedSubviews(
            totalWorkRow,
            insuranceDeductionRow,
            employmentInsuranceRow,
            healthInsuranceRow,
            industrialAccidentRow,
            nationalPensionRow,
            incomeTaxRow
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

        detailStackView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        expandToggleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(22)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().inset(8)
        }

        expandToggleImageView.snp.prepareConstraints {
            self.expandToggleTopToHeaderConstraint = $0.top.equalTo(headerView.snp.bottom).offset(8).constraint
            self.expandToggleTopToDetailConstraint = $0.top.equalTo(detailStackView.snp.bottom).offset(8).constraint
        }

        expandToggleTopToHeaderConstraint?.activate()
        expandToggleTopToDetailConstraint?.deactivate()
    }

    private func updateExpandToggleConstraints(isExpanded: Bool) {
        print("제약조건 업데이트: \(isExpanded)")
        if isExpanded {
            expandToggleTopToHeaderConstraint?.deactivate()
            expandToggleTopToDetailConstraint?.activate()
        } else {
            expandToggleTopToDetailConstraint?.deactivate()
            expandToggleTopToHeaderConstraint?.activate()
        }

        if isExpanded {
            // 펼칠 때는 애니메이션 적용
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.contentView.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
        } else {
            // 접을 때는 애니메이션 없이 즉시 적용
            self.layoutIfNeeded()
            self.contentView.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }

    func toggleDetailView(isExpanded: Bool) {
        print("toggleDetailView 호출: \(isExpanded)")
        detailStackView.isHidden = !isExpanded
        expandToggleImageView.image = isExpanded ? .chevronUnfolded : .chevronFolded
        
        updateExpandToggleConstraints(isExpanded: isExpanded)
    }

    func setupButtonMenu(with actions: [UIAction]) {
        let menu = UIMenu(children: actions)

        self.menuButton.menu = menu
        self.menuButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - 컴포넌트 스타일 적용 메서드
    private func setTotalEarnedLabel(amount: String, isTemporary: Bool) {
        guard !isTemporary else {
            totalEarnedLabel.text = "현재까지 번 금액"
            return
        }

        let fullText = "현재까지 \(amount)원"

        var attributedString = AttributedString(fullText)

        var baseContainer = AttributeContainer()
        baseContainer.font = .bodyMedium(14)
        baseContainer.foregroundColor = .gray900

        var boldContainer = AttributeContainer()
        boldContainer.font = .headBold(16)
        boldContainer.foregroundColor = .gray900

        attributedString.setAttributes(baseContainer)
        
        let boldText = "\(amount)원"
        if let range = attributedString.range(of: boldText) {
            attributedString[range].setAttributes(boldContainer)
        }

        totalEarnedLabel.attributedText = NSAttributedString(attributedString)
    }
}

extension Reactive where Base: MyWorkSpaceCell {
    var toggleExpanded: Binder<Bool> {
        Binder(base) { cell, isExpanded in
            cell.toggleDetailView(isExpanded: isExpanded)
        }
    }
    
    var disposeBag: DisposeBag {
        return base.disposeBag
    }
}
