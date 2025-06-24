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

final class WorkerEditViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Subviews

    private let navigationBar: BaseNavigationBar

    private let salaryInfoView: SalaryInfoView
    private let workConditionView: WorkConditionView
    private let labelView: LabelView
    private let registerButton = UIButton(type: .system)

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(
        navigationTitle: String,

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
        dotColor: UIColor?
    ) {
        self.navigationBar = BaseNavigationBar(title: navigationTitle)

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
