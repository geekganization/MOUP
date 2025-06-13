//
//  HomeHeaderView.swift
//  Routory
//
//  Created by 송규섭 on 6/10/25.
//

import UIKit

final class HomeHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    static let identifier = "HomeHeaderView"
    // MARK: - UI Components

    // 현재 기준 총 급여 카드 관련
    private let totalMonthlySalaryCardView = CardView()
    private let totalMonthlySalaryTitleLabel = UILabel().then {
        $0.text = "총 급여"
        $0.font = .headBold(20)
        $0.textColor = .gray900
        $0.textAlignment = .left
    }
    private let totalMonthlySalaryLabel = UILabel().then {
        $0.text = "00,000원"
        $0.font = .headBold(20)
        $0.textColor = .gray900
        $0.textAlignment = .right
    }
    private let separatorLine = UIView().then {
        $0.backgroundColor = .gray300
    }
    private let monthlyChangeCommentLabel = UILabel().then {
        $0.text = "지난달 오늘 대비 5만원 더 벌었어요!"
        $0.font = .bodyMedium(14)
        $0.textColor = .gray700
        $0.textAlignment = .right
    }

    // 루틴 섹션 타이틀 레이블
    private let routineSectionLabel = UILabel().then {
        $0.text = "루틴"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.textAlignment = .center
    }
    private lazy var routineCardStackView = UIStackView().then {
        $0.spacing = 12
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }

    // 오늘의 루틴 카드 관련
    private lazy var todaysRoutineCardView = CardView()
    private lazy var todaysRoutineTitleLabel = UILabel().then {
        $0.text = "오늘의 루틴"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    private lazy var todaysRoutineChevronIcon = UIImageView().then {
        $0.image = .chevronRight
    }
    private lazy var todaysRoutineNoticeLabel = UILabel().then {
        $0.text = "오늘 루틴 총 3개 있어요!"
        $0.textColor = .gray700
        $0.font = .bodyMedium(12)
        $0.numberOfLines = 1
    }

    // 전체 루틴 카드 관련
    private lazy var allRoutineCardView = CardView()
    private lazy var allRoutineTitleLabel = UILabel().then {
        $0.text = "전체 루틴"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    private lazy var allRoutineChevronIcon = UIImageView().then {
        $0.image = .chevronRight
    }
    private lazy var allRoutineNoticeLabel = UILabel().then {
        $0.text = "모든 루틴을 확인해 보세요!"
        $0.textColor = .gray700
        $0.font = .bodyMedium(12)
        $0.numberOfLines = 1
    }

    // 나의 근무지 섹션 헤더
    private let workSpaceSectionLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.text = "나의 근무지" // TODO: - 역할 확인 실패 시 띄워줄 값을 필요로 할지
    }

    private let plusButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .plus.withTintColor(.gray900, renderingMode: .alwaysOriginal)
        config.contentInsets = .init(top: 14.5, leading: 14.5, bottom: 14.5, trailing: 14.5)
        $0.configuration = config
    }

    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(with title: String) {
        workSpaceSectionLabel.text = title
    }
}

private extension HomeHeaderView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(totalMonthlySalaryCardView, routineSectionLabel, routineCardStackView, workSpaceSectionLabel, plusButton)
        routineCardStackView.addArrangedSubviews(todaysRoutineCardView, allRoutineCardView)
        totalMonthlySalaryCardView.addSubviews(totalMonthlySalaryTitleLabel, totalMonthlySalaryLabel, separatorLine, monthlyChangeCommentLabel)
        todaysRoutineCardView.addSubviews(todaysRoutineTitleLabel, todaysRoutineChevronIcon, todaysRoutineNoticeLabel)
        allRoutineCardView.addSubviews(allRoutineTitleLabel, allRoutineChevronIcon, allRoutineNoticeLabel)
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundView = UIView().then {
            $0.backgroundColor = .systemBackground
        }
    }

    // MARK: - setConstraints
    func setConstraints() {
        // 최상단 총 급여 레이아웃
        totalMonthlySalaryCardView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(121)
        }

        totalMonthlySalaryTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        totalMonthlySalaryLabel.snp.makeConstraints {
            $0.top.equalTo(totalMonthlySalaryTitleLabel.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        separatorLine.snp.makeConstraints {
            $0.top.equalTo(totalMonthlySalaryLabel.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }

        monthlyChangeCommentLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        // 루틴 관련 레이아웃
        routineSectionLabel.snp.makeConstraints {
            $0.top.equalTo(totalMonthlySalaryCardView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(16)
        }

        routineCardStackView.snp.makeConstraints {
            $0.top.equalTo(routineSectionLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(81)
        }

        // 오늘의 루틴 레이아웃
        todaysRoutineTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }

        todaysRoutineChevronIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(todaysRoutineTitleLabel.snp.centerY)
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }

        todaysRoutineNoticeLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        // 전체 루틴 레이아웃
        allRoutineTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }

        allRoutineChevronIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(allRoutineTitleLabel.snp.centerY)
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }

        allRoutineNoticeLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        workSpaceSectionLabel.snp.makeConstraints {
            $0.top.equalTo(allRoutineCardView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }

        plusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalTo(workSpaceSectionLabel.snp.centerY)
            $0.size.equalTo(44)
        }
    }
}

