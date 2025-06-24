//
//  WorkplaceRegistrationContentView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class WorkplaceRegistrationContentView: UIView {

    // MARK: - Subviews

    let workplaceInfoView: WorkplaceInfoView
    let salaryInfoView: SalaryInfoView
    let workConditionView: WorkConditionView
    let labelView: LabelView
    let registerButton = UIButton(type: .system)
    let registerBtnTitle: String
    let workplaceId: String
    let isWorkerManagerShow: Bool

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }

    // MARK: - Initializer

    init(
        workplaceId: String,
        isEdit: Bool,
        isWorkerManagerShow: Bool,
        
        nameValue: String?,
        categoryValue: String?,
        
        salaryTypeValue: String,
        salaryCalcValue: String,
        fixedSalaryValue: String,
        hourlyWageValue: String,
        payDateValue: String,
        payWeekdayValue: String,

        isFourMajorSelected: Bool,
        isNationalPensionSelected: Bool,
        isHealthInsuranceSelected: Bool,
        isEmploymentInsuranceSelected: Bool,
        isIndustrialAccidentInsuranceSelected: Bool,
        isIncomeTaxSelected: Bool,
        isWeeklyAllowanceSelected: Bool,
        isNightAllowanceSelected: Bool,

        labelTitle: String,
        showDot: Bool,
        dotColor: UIColor?,
        
        registerBtnTitle: String
    ) {
        self.isWorkerManagerShow = isWorkerManagerShow
        
        self.workplaceInfoView = WorkplaceInfoView(
            nameValue: nameValue,
            categoryValue: categoryValue,
            workplaceId: workplaceId
        )
        
        self.salaryInfoView = SalaryInfoView(
            typeValue: salaryTypeValue,
            calcValue: salaryCalcValue,
            fixedSalaryValue: fixedSalaryValue,
            hourlyWageValue: hourlyWageValue,
            payDateValue: payDateValue,
            payWeekdayValue: payWeekdayValue
        )

        self.workConditionView = WorkConditionView(
            isFourMajorSelected: isFourMajorSelected,
            isNationalPensionSelected: isNationalPensionSelected,
            isHealthInsuranceSelected: isHealthInsuranceSelected,
            isEmploymentInsuranceSelected: isEmploymentInsuranceSelected,
            isIndustrialAccidentInsuranceSelected: isIndustrialAccidentInsuranceSelected,
            isIncomeTaxSelected: isIncomeTaxSelected,
            isWeeklyAllowanceSelected: isWeeklyAllowanceSelected,
            isNightAllowanceSelected: isNightAllowanceSelected
        )

        self.labelView = LabelView(
            title: labelTitle,
            showDot: showDot,
            dotColor: dotColor
        )
        
        self.registerBtnTitle = registerBtnTitle
        self.workplaceId = workplaceId
        super.init(frame: .zero)
        setupUI()
        layout()
        setReadMode(isEdit)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white

        [workplaceInfoView, salaryInfoView, workConditionView, labelView, registerButton]
            .forEach { stackView.addArrangedSubview($0) }

        registerButton.setTitle(registerBtnTitle, for: .normal)
        registerButton.setTitleColor(.primary50, for: .normal)
        registerButton.backgroundColor = .primary500
        registerButton.titleLabel?.font = .buttonSemibold(18)
        registerButton.layer.cornerRadius = 8
        registerButton.isEnabled = true
        registerButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        addSubview(stackView)
    }

    // MARK: - Layout

    private func layout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WorkplaceRegistrationContentView {
    func setReadMode(_ isRead: Bool) {
        workplaceInfoView.isUserInteractionEnabled = !isRead
        salaryInfoView.isUserInteractionEnabled = !isRead
        workConditionView.isUserInteractionEnabled = !isRead
        labelView.isUserInteractionEnabled = !isRead
        registerButton.isHidden = isRead
            
        if isRead {
            workplaceInfoView.disableEditing()
            workplaceInfoView.hideWorkerManagerRow()
            salaryInfoView.disableEditing()
            labelView.disableEditing()
        } else {
            workplaceInfoView.enableEditing()
            if isWorkerManagerShow {
                workplaceInfoView.showWorkerManagerRow()
            } else {
                workplaceInfoView.hideWorkerManagerRow()
            }
            salaryInfoView.enableEditing()
            labelView.enableEditing()
        }
    }
}

