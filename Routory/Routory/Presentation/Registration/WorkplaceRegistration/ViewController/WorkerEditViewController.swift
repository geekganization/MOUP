//
//  WorkerEditViewController.swift
//  Routory
//
//  Created by tlswo on 6/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseAuth

final class WorkerEditViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Subviews
    private let workerPlaceId: String
    
    private let navigationBar: BaseNavigationBar
    private let workerDetail: WorkerDetail

    private let salaryInfoView: SalaryInfoView
    private let workConditionView: WorkConditionView
    private let labelView: LabelView
    private let registerButton = UIButton(type: .system)

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(
        workerPlaceId: String,

        workerDetail: WorkerDetail,

        labelTitle: String,
        showDot: Bool,
        dotColor: UIColor?
    ) {
        self.workerDetail = workerDetail
        
        self.navigationBar = BaseNavigationBar(title: workerDetail.workerName)

        self.salaryInfoView = SalaryInfoView(
            typeValue: workerDetail.wageCalcMethod, // 매월
            calcValue: workerDetail.wageType, // 고정 // 시급
            fixedSalaryValue: String(workerDetail.wage), // 3000000000
            hourlyWageValue: String(workerDetail.wage), // 10000
            payDateValue: String(workerDetail.payDay)+"일", // 24일
            payWeekdayValue: workerDetail.payWeekday // 금요일
        )

        self.workConditionView = WorkConditionView(
            isFourMajorSelected: workerDetail.employmentInsurance,
            isNationalPensionSelected: workerDetail.nationalPension,
            isHealthInsuranceSelected: workerDetail.healthInsurance,
            isEmploymentInsuranceSelected: workerDetail.employmentInsurance,
            isIndustrialAccidentInsuranceSelected: workerDetail.industrialAccident,
            isIncomeTaxSelected: workerDetail.incomeTax,
            isWeeklyAllowanceSelected: workerDetail.weeklyAllowance,
            isNightAllowanceSelected: workerDetail.nightAllowance,
        )

        self.labelView = LabelView(
            title: labelTitle,
            showDot: showDot,
            dotColor: dotColor
        )
        
        self.workerPlaceId = workerPlaceId

        super.init(nibName: nil, bundle: nil)

        salaryInfoView.delegate = self
        labelView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        layout()
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        registerButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .white

        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            salaryInfoView,
            workConditionView,
            labelView,
            registerButton
        ].forEach { contentView.addSubview($0) }

        registerButton.setTitle("적용하기", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .buttonSemibold(18)
        registerButton.backgroundColor = .primary500
        registerButton.layer.cornerRadius = 8
        registerButton.isEnabled = true
    }

    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Layout

    private func layout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
            $0.bottom.equalTo(registerButton.snp.bottom)
        }

        salaryInfoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        workConditionView.snp.makeConstraints {
            $0.top.equalTo(salaryInfoView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        labelView.snp.makeConstraints {
            $0.top.equalTo(workConditionView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        registerButton.snp.makeConstraints {
            $0.top.equalTo(labelView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
    }
    
    @objc private func didTapRegisterButton() {
        handleRegisterButtonTapped()
    }
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.6
        }
    }

    @objc func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }
    
    private func handleRegisterButtonTapped() {
        
        let selected = workConditionView.getSelectedConditions()
        let salaryType = salaryInfoView.getTypeValue()
        let salaryCalc = salaryInfoView.getCalcValue()
        let fixedSalary = salaryInfoView.getFixedSalaryValue()
        let hourlyWage = salaryInfoView.getHourlyWageValue()
        let payWeekday = salaryInfoView.getPayWeekdayValue()
        let payDate = salaryInfoView.getPayDateValue()
        let selectedConditions = workConditionView.getSelectedConditions()
        let label = labelView.getColorLabelData()
        
        let wage: Int = {
            switch salaryCalc {
            case "시급":
                return (parseCurrencyStringToInt(hourlyWage))
            case "고정":
                return (parseCurrencyStringToInt(fixedSalary))
            default:
                return (0)
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
        
        let updated = WorkerDetail(
            workerName: workerDetail.workerName,
            wage: wage,
            wageCalcMethod: salaryType,
            wageType: salaryCalc,
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
        
        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("유저 UID가 존재하지 않음")
            return
        }
        
        // 데이터 업데이트 로직
        // updateWorkerDetail
        print(workerPlaceId,uid,updated)
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - SalaryInfoViewDelegate

extension WorkerEditViewController: SalaryInfoViewDelegate {
    func didTapTypeRow() {
        let items = ["매월", "매주", "매일"].map {
            SelectionViewController<String>.Item(title: $0, icon: nil, value: $0)
        }

        let vc = SelectionViewController<String>(
            title: "급여 유형",
            description: "급여 유형을 선택해주세요",
            items: items,
            selected: salaryInfoView.getTypeValue()
        )
        vc.onSelect = { [weak self] selected in
            self?.salaryInfoView.updateTypeValue(selected)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapCalcRow() {
        let items = ["시급", "고정"].map {
            SelectionViewController<String>.Item(title: $0, icon: nil, value: $0)
        }

        let vc = SelectionViewController<String>(
            title: "급여 계산",
            description: "급여 계산방법을 선택해주세요",
            items: items,
            selected: salaryInfoView.getCalcValue()
        )
        vc.onSelect = { [weak self] selected in
            self?.salaryInfoView.updateCalcValue(selected)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapFixedSalaryRow() {
        let vc = TextInputViewController(
            title: "고정급",
            description: "고정급을 입력해주세요",
            placeholder: "3,000,000",
            keyboardType: .numberPad,
            formatter: { input in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: Int(input) ?? 0)) ?? ""
            },
            validator: { input in
                Int(input.replacingOccurrences(of: ",", with: "")) != nil
            }
        )
        vc.onComplete = { [weak self] value in
            self?.salaryInfoView.updateFixedSalaryValue(value)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapHourlyWageRow() {
        let vc = TextInputViewController(
            title: "시급",
            description: "시급을 입력해주세요",
            placeholder: "10,030",
            keyboardType: .numberPad,
            formatter: { input in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: Int(input) ?? 0)) ?? ""
            },
            validator: { input in
                Int(input.replacingOccurrences(of: ",", with: "")) != nil
            }
        )
        vc.onComplete = { [weak self] value in
            self?.salaryInfoView.updateHourlyWageValue(value)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapPayDateRow() {
        let days = (1...31).map { "\($0)일" }
        let vc = ReusablePickerViewController(data: [days]) { [weak self] selected in
            let index = selected[0]
            self?.salaryInfoView.updatePayDateValue(days[index])
        }

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }

    func didTapPayWeekdayRow() {
        let weekDays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
        let vc = ReusablePickerViewController(data: [weekDays]) { [weak self] selected in
            let index = selected[0]
            self?.salaryInfoView.updatePayWeekdayValue(weekDays[index])
        }

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
}

// MARK: - LabelViewDelegate

extension WorkerEditViewController: LabelViewDelegate {
    func labelViewDidTapSelectColor(_ sender: LabelView) {
        let vc = ColorSelectionViewController()
        vc.onSelect = { [weak self] color in
            self?.labelView.updateLabelName(color.name, color: color.color)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
