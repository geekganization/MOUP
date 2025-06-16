//
//  WorkerWorkplaceRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class WorkerWorkplaceRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = WorkplaceRegistrationContentView(workplaceTitle: "근무지 *")

    private var delegateHandler: WorkplaceRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        configureShiftNavigationBar(
            for: self,
            title: "새 근무지 등록",
            target: self,
            action: #selector(didTapBack)
        )
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        delegateHandler = WorkplaceRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.salaryInfoView.delegate = delegateHandler
        contentView.workplaceInfoView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler

        contentView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchDown(_:)), for: .touchDown)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
//    @objc func didTapRegister() {
//        print("알바생 새 근무지 등록 데이터")
//        let name = contentView.workplaceInfoView.getName()
//        let category = contentView.workplaceInfoView.getCategory()
//        let salaryType = contentView.salaryInfoView.getTypeValue()
//        let salaryCalc = contentView.salaryInfoView.getCalcValue()
//        let fixedSalary = contentView.salaryInfoView.getFixedSalaryValue()
//        let hourlyWage = contentView.salaryInfoView.getHourlyWageValue()
//        let payWeekday = contentView.salaryInfoView.getPayWeekdayValue()
//        let payDate = contentView.salaryInfoView.getPayDateValue()
//        let workConditions = contentView.workConditionView.getSelectedConditions()
//        let label = contentView.labelView.getColorLabelData()
//
//        print("이름:", name)
//        print("카테고리:", category)
//        print("급여 유형:", salaryType)
//        print("급여 계산:", salaryCalc)
//        print("고정급:", fixedSalary)
//        print("시급:", hourlyWage)
//        print("급여일:", payDate)
//        print("급여일(요일):", payWeekday)
//        print("근무 조건:", workConditions)
//        print("라벨:", label)
//        
//        print(Workplace(workplacesName: name, category: category, ownerId: "", inviteCode: "", isOfficial: false))
//    }
    
    @objc func didTapRegister() {
        let name = contentView.workplaceInfoView.getName()
        let category = contentView.workplaceInfoView.getCategory()
        let salaryType = contentView.salaryInfoView.getTypeValue() // "매월", "매주", "매일"
        let salaryCalc = contentView.salaryInfoView.getCalcValue()
        let fixedSalary = contentView.salaryInfoView.getFixedSalaryValue()
        let hourlyWage = contentView.salaryInfoView.getHourlyWageValue()
        let payWeekday = contentView.salaryInfoView.getPayWeekdayValue()
        let payDate = contentView.salaryInfoView.getPayDateValue()
        let selectedConditions = contentView.workConditionView.getSelectedConditions() // [String]
        let label = contentView.labelView.getColorLabelData()
        
        let (wage, wageCalcMethod): (Int, String) = {
            switch salaryType {
            case "매월":
                return (parseCurrencyStringToInt(fixedSalary), "monthly")
            case "매주", "매일":
                return (parseCurrencyStringToInt(hourlyWage), "hourly")
            default:
                return (0, "hourly")
            }
        }()

        let employmentInsurance = selectedConditions.contains("고용보험")
        let healthInsurance = selectedConditions.contains("건강보험")
        let industrialAccident = selectedConditions.contains("산재보험")
        let nationalPension = selectedConditions.contains("국민연금")
        let incomeTax = selectedConditions.contains("소득세")
        let weeklyAllowance = selectedConditions.contains("주휴수당")
        let nightAllowance = selectedConditions.contains("야간수당*")

        let breakTimeMinutes = 0
        
        let workPlace = Workplace(workplacesName: name, category: category, ownerId: "", inviteCode: "", isOfficial: false)

        let worker = WorkerDetail(
            workerName: "",
            wage: wage,
            wageCalcMethod: wageCalcMethod,
            wageType: salaryType,
            weeklyAllowance: weeklyAllowance,
            payDay: parseDateStringToInt(payDate),
            payWeekday: payWeekday,
            breakTimeMinutes: breakTimeMinutes,
            employmentInsurance: employmentInsurance,
            healthInsurance: healthInsurance,
            industrialAccident: industrialAccident,
            nationalPension: nationalPension,
            incomeTax: incomeTax,
            nightAllowance: nightAllowance,
            color: label
        )

        print(workPlace,worker)
    }
}
