//
//  SalaryInfoView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Delegate Protocol

protocol SalaryInfoViewDelegate: AnyObject {
    func didTapTypeRow()
    func didTapCalcRow()
    func didTapFixedSalaryRow()
    func didTapHourlyWageRow()
    func didTapPayDateRow()
    func didTapPayWeekdayRow()
}

// MARK: - View

final class SalaryInfoView: UIView, ValueRowViewDelegate, FieldRowViewDelegate {

    weak var delegate: SalaryInfoViewDelegate?

    private let typeRow = ValueRowView(title: "급여 유형", value: "매월")
    private let calcRow = ValueRowView(title: "급여 계산", value: "고정")
    private let fixedSalaryRow = ValueRowView(title: "고정급", value: "1,000,000원")
    private let hourlyWageRow = ValueRowView(title: "시급", value: "10,030원")
    private let payDateRow = FieldRowView(title: "급여일", value: "25일")
    private let payWeekdayRow = FieldRowView(title: "급여일(요일)", value: "월요일")

    private var boxStackView: UIStackView!

    init() {
        super.init(frame: .zero)
        setup()
        updateVisibleSalaryRows()
        updateVisibleDateRows()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        typeRow.delegate = self
        calcRow.delegate = self
        fixedSalaryRow.delegate = self
        hourlyWageRow.delegate = self
        payDateRow.delegate = self
        payWeekdayRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "급여"
            $0.font = .headBold(18)
        }

        hourlyWageRow.isHidden = true

        boxStackView = makeBoxedStackView(with: [
            typeRow,
            calcRow,
            fixedSalaryRow,
            hourlyWageRow,
            payDateRow,
            payWeekdayRow
        ])

        let stack = UIStackView(arrangedSubviews: [titleLabel, boxStackView]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func updateVisibleSalaryRows() {
        let isFixed = calcRow.getValueData() == "고정"
        fixedSalaryRow.isHidden = !isFixed
        hourlyWageRow.isHidden = isFixed
    }
    
    private func updateVisibleDateRows() {
        let typeValue = typeRow.getValueData()

        switch typeValue {
        case "매월":
            payDateRow.isHidden = false
            payWeekdayRow.isHidden = true
        case "매주":
            payDateRow.isHidden = true
            payWeekdayRow.isHidden = false
        case "매일":
            payDateRow.isHidden = true
            payWeekdayRow.isHidden = true
        default:
            payDateRow.isHidden = true
            payWeekdayRow.isHidden = true
        }
    }

    // MARK: - ValueRowViewDelegate

    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        switch row {
        case typeRow:
            delegate?.didTapTypeRow()
        case calcRow:
            delegate?.didTapCalcRow()
        case fixedSalaryRow:
            delegate?.didTapFixedSalaryRow()
        case hourlyWageRow:
            delegate?.didTapHourlyWageRow()
        default:
            break
        }
    }

    // MARK: - FieldRowViewDelegate

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        switch row {
        case payDateRow:
            delegate?.didTapPayDateRow()
        case payWeekdayRow:
            delegate?.didTapPayWeekdayRow()
        default:
            break
        }
    }

    // MARK: - Public API

    func updateTypeValue(_ value: String) {
        typeRow.updateValue(value)
        updateVisibleDateRows()
    }

    func updateCalcValue(_ value: String) {
        calcRow.updateValue(value)
        updateVisibleSalaryRows()
    }

    func updateFixedSalaryValue(_ value: String) {
        fixedSalaryRow.updateValue(value)
    }

    func updateHourlyWageValue(_ value: String) {
        hourlyWageRow.updateValue(value)
    }

    func updatePayDateValue(_ value: String) {
        payDateRow.updateValue(value)
    }

    func updatePayWeekdayValue(_ value: String) {
        payWeekdayRow.updateValue(value)
    }

    func getTypeValue() -> String {
        return typeRow.getValueData()
    }

    func getCalcValue() -> String {
        return calcRow.getValueData()
    }

    func getFixedSalaryValue() -> String {
        return fixedSalaryRow.getValueData()
    }

    func getHourlyWageValue() -> String {
        return hourlyWageRow.getValueData()
    }

    func getPayDateValue() -> String {
        return payDateRow.getData()
    }

    func getPayWeekdayValue() -> String {
        return payWeekdayRow.getData()
    }
}
