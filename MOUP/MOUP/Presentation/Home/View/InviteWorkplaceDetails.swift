//
//  InviteWorkplaceDetails.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class InviteWorkplaceDetails: UIView {
    
    // MARK: - Properties
    
    let backButtonDidTap = PublishRelay<Void>()
    let paymentCycleRowDidTap = PublishRelay<Void>()
    let paymentMethodRowDidTap = PublishRelay<Void>()
    let wageCalculationTypeRowDidTap = PublishRelay<Void>()
    let paydayRowDidTap = PublishRelay<Void>()
    let colorPickerRowDidTap = PublishRelay<Void>()
    let completeButtonDidTap = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let navigationBar = BaseNavigationBar(title: "근무지 이름")
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let workplaceSectionHeader = SectionHeaderView(
        title: "근무지",
        isRequired: false
    )
    
    private let workplaceSectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let workplaceNameRow = DefaultValueRowView(
        title: "이름",
        value: "모업커피"
    )
    
    private let workplaceCategoryRow = DefaultValueRowView(
        title: "카테고리",
        value: "카페",
        isLast: true
    )
    
    private let wageSectionHeader = SectionHeaderView(
        title: "급여",
        isRequired: true
    )
    
    private let wageSectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let paymentCycleRow = ArrowValueRowView(
        title: "급여 유형",
        value: "매월"
    )
    
    private let paymentMethodRow = ArrowValueRowView(
        title: "급여 계산",
        value: "고정"
    )
    
    private let wageCalculationTypeRow = DefaultValueRowView(
        title: "고정급",
        value: "1,000,000원"
    )
    
    private let paydayRow = DateChipValueRowView(
        title: "급여일",
        value: "25일",
        isLast: true
    )
    
    private let workConditionSectionHeader = SectionHeaderView(
        title: "근무 조건",
        isRequired: true
    )
    
    private let workConditionSectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let socialInsuranceRow = CheckBoxRowView(
        title: "4대 보험",
        showInfoIcon: true
    )
    private let nationalPensionRow = CheckBoxRowView(title: "국민연금")
    private let healthInsuranceRow = CheckBoxRowView(title: "건강보험")
    private let employmentInsuranceRow = CheckBoxRowView(title: "고용보험")
    private let industrialAccidentInsuranceRow = CheckBoxRowView(title: "산재보험")
    private let incomeTaxRow = CheckBoxRowView(title: "소득세")
    private let weeklyAllowanceRow = CheckBoxRowView(title: "주휴수당")
    private let nightAllowanceRow = CheckBoxRowView(
        title: "야간수당",
        showInfoIcon: true,
        isLast: true
    )
    
    private let guideMessageLabel = UILabel().then {
        $0.text = "* 오후 10시 이후 야간수당을 받는 경우 체크해주세요"
        $0.font = .bodyMedium(12)
        $0.textColor = .gray700
    }
    
    private let colorPickerSectionHeader = SectionHeaderView(
        title: "라벨",
        isRequired: false
    )
    
    private let colorPickerSectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let colorPickerRow = ColorPickerRowView()
    
    private let completeButton = BaseButton(title: "입력완료").then {
        $0.isEnabled = false
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension InviteWorkplaceDetails {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            scrollView,
            completeButton
        )
        
        scrollView.addSubview(
            contentView
        )
        
        contentView.addSubviews(
            workplaceSectionHeader,
            workplaceSectionStackView,
            wageSectionHeader,
            wageSectionStackView,
            workConditionSectionHeader,
            workConditionSectionStackView,
            guideMessageLabel,
            colorPickerSectionHeader,
            colorPickerSectionStackView
        )
        
        workplaceSectionStackView.addArrangedSubviews(
            workplaceNameRow,
            workplaceCategoryRow
        )
        
        wageSectionStackView.addArrangedSubviews(
            paymentCycleRow,
            paymentMethodRow,
            wageCalculationTypeRow,
            paydayRow
        )
        
        workConditionSectionStackView.addArrangedSubviews(
            socialInsuranceRow,
            nationalPensionRow,
            healthInsuranceRow,
            employmentInsuranceRow,
            industrialAccidentInsuranceRow,
            incomeTaxRow,
            weeklyAllowanceRow,
            nightAllowanceRow
        )
        
        colorPickerSectionStackView.addArrangedSubview(colorPickerRow)
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(48)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.bottom.equalTo(completeButton.snp.top)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.bottom.equalTo(colorPickerSectionStackView.snp.bottom).offset(34)
        }
        
        workplaceSectionHeader.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview()
        }
        
        workplaceSectionStackView.snp.makeConstraints {
            $0.top.equalTo(workplaceSectionHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        workplaceNameRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        workplaceCategoryRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        wageSectionHeader.snp.makeConstraints {
            $0.top.equalTo(workplaceSectionStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
        }
        
        wageSectionStackView.snp.makeConstraints {
            $0.top.equalTo(wageSectionHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        paymentCycleRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        paymentMethodRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        wageCalculationTypeRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        paydayRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        workConditionSectionHeader.snp.makeConstraints {
            $0.top.equalTo(wageSectionStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
        }
        
        workConditionSectionStackView.snp.makeConstraints {
            $0.top.equalTo(workConditionSectionHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        [
            socialInsuranceRow,
            nationalPensionRow,
            healthInsuranceRow,
            employmentInsuranceRow,
            industrialAccidentInsuranceRow,
            incomeTaxRow,
            weeklyAllowanceRow,
            nightAllowanceRow
        ].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }
        
        guideMessageLabel.snp.makeConstraints {
            $0.trailing.equalTo(workConditionSectionStackView.snp.trailing)
            $0.top.equalTo(workConditionSectionStackView.snp.bottom).offset(4)
        }
        
        colorPickerSectionHeader.snp.makeConstraints {
            $0.top.equalTo(workConditionSectionStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
        }
        
        colorPickerSectionStackView.snp.makeConstraints {
            $0.top.equalTo(colorPickerSectionHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        colorPickerRow.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        completeButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        navigationBar.rx.backBtnTapped
            .bind(to: backButtonDidTap)
            .disposed(by: disposeBag)
        
        paymentCycleRow.tapRelay
            .bind(to: paymentCycleRowDidTap)
            .disposed(by: disposeBag)
        
        paymentMethodRow.tapRelay
            .bind(to: paymentMethodRowDidTap)
            .disposed(by: disposeBag)
        
        wageCalculationTypeRow.tapRelay
            .bind(to: wageCalculationTypeRowDidTap)
            .disposed(by: disposeBag)
        
        paydayRow.tapRelay
            .bind(to: paydayRowDidTap)
            .disposed(by: disposeBag)
        
        socialInsuranceRow.checkBoxButtonDidTap
            .bind { [weak self] isChecked in
                guard let self else { return }
                self.nationalPensionRow.setChecked(isChecked)
                self.healthInsuranceRow.setChecked(isChecked)
                self.employmentInsuranceRow.setChecked(isChecked)
                self.industrialAccidentInsuranceRow.setChecked(isChecked)
            }
            .disposed(by: disposeBag)
        
        colorPickerRow.tapRelay
            .bind(to: colorPickerRowDidTap)
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(to: completeButtonDidTap)
            .disposed(by: disposeBag)
    }
}
