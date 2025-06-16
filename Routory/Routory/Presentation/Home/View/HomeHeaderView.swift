//
//  HomeHeaderView.swift
//  Routory
//
//  Created by 송규섭 on 6/10/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    static let identifier = "HomeHeaderView"

    fileprivate var reuseBag = DisposeBag()
    // MARK: - UI Components

    // 현재 기준 총 급여 카드 관련
    private let monthlyAmountCardView = CardView()
    private let monthlyAmountTitleLabel = UILabel().then {
        $0.text = "총 급여"
        $0.font = .headBold(20)
        $0.textColor = .gray900
        $0.textAlignment = .left
    }
    private let monthlyAmountLabel = UILabel().then {
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
    fileprivate lazy var todaysRoutineCardView = CardView()
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
    fileprivate lazy var allRoutineCardView = CardView()
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

    // 나의 근무지 섹션 타이틀
    private let firstSectionLabel = UILabel().then {
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

    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }

    // MARK: - Public Methods
    func update(with headerData: DummyHomeHeaderInfo) {
        // firstSectionLabel, totalMonthly~는 역할 데이터가 있어야 하므로 임시 보류
        monthlyAmountTitleLabel.text = "\(headerData.monthlyTitle)" // 역할 별로 다르게 분기
        monthlyAmountLabel.text = "\(headerData.monthlyAmount.withComma)원"
        monthlyChangeCommentLabel.text = {
            if headerData.amountDifference >= 0 {
                "지난 달 오늘 대비 \(headerData.amountDifference.withComma)원 더 벌었어요!"
            } else {
                "지난 달 오늘 대비 \(abs(headerData.amountDifference).withComma)원 덜 벌었어요"
            }

        }()
        todaysRoutineNoticeLabel.attributedText = createRoutineNoticeText(count: headerData.todayRoutineCount)
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
        contentView.addSubviews(monthlyAmountCardView, routineSectionLabel, routineCardStackView, firstSectionLabel, plusButton)
        routineCardStackView.addArrangedSubviews(todaysRoutineCardView, allRoutineCardView)
        monthlyAmountCardView.addSubviews(monthlyAmountTitleLabel, monthlyAmountLabel, separatorLine, monthlyChangeCommentLabel)
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
        monthlyAmountCardView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(121)
        }

        monthlyAmountTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        monthlyAmountLabel.snp.makeConstraints {
            $0.top.equalTo(monthlyAmountTitleLabel.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        separatorLine.snp.makeConstraints {
            $0.top.equalTo(monthlyAmountLabel.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }

        monthlyChangeCommentLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        // 루틴 관련 레이아웃
        routineSectionLabel.snp.makeConstraints {
            $0.top.equalTo(monthlyAmountCardView.snp.bottom).offset(20)
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

        firstSectionLabel.snp.makeConstraints {
            $0.top.equalTo(allRoutineCardView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        plusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalTo(firstSectionLabel.snp.centerY)
            $0.size.equalTo(44)
        }
    }

    func createRoutineNoticeText(count: Int) -> NSAttributedString {
        let text = "오늘 루틴 총 \(count)개 있어요!"
        let attributedString = NSMutableAttributedString(string: text)

        // 전체 텍스트 기본 스타일
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.gray700,
                                      range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.font,
                                      value: UIFont.bodyMedium(12),
                                      range: NSRange(location: 0, length: text.count))

        // 숫자 부분만 강조
        let countString = "\(count)"
        if let range = text.range(of: countString) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.primary500,
                                          range: nsRange)
            attributedString.addAttribute(.font,
                                          value: UIFont.headBold(12),
                                          range: nsRange)
        }

        return attributedString
    }
}

extension Reactive where Base: HomeHeaderView {
    var todaysRoutineCardTapped: ControlEvent<Void> {
        let tapGesture = UITapGestureRecognizer()
        base.todaysRoutineCardView.addGestureRecognizer(tapGesture)
        base.todaysRoutineCardView.isUserInteractionEnabled = true

        return ControlEvent(events: tapGesture.rx.event.map { _ in })
    }

    var allRoutineCardTapped: ControlEvent<Void> {
        let tapGesture = UITapGestureRecognizer()
        base.allRoutineCardView.addGestureRecognizer(tapGesture)
        base.allRoutineCardView.isUserInteractionEnabled = true

        return ControlEvent(events: tapGesture.rx.event.map { _ in })
    }
}
