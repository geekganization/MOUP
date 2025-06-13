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
    func didTapPayDateRow()
}

// MARK: - View

final class SalaryInfoView: UIView, ValueRowViewDelegate, FieldRowViewDelegate {

    // MARK: - Delegate

    weak var delegate: SalaryInfoViewDelegate?

    // MARK: - Subviews

    private let typeRow = ValueRowView(title: "급여 유형", value: "매월")
    private let calcRow = ValueRowView(title: "급여 계산", value: "고정")
    private let fixedSalaryRow = ValueRowView(title: "고정급", value: "1,000,000원")
    private let payDateRow = FieldRowView(title: "급여일", value: "25일")

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        typeRow.delegate = self
        calcRow.delegate = self
        fixedSalaryRow.delegate = self
        payDateRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "급여"
            $0.font = .headBold(18)
        }

        let box = makeBoxedStackView(with: [typeRow, calcRow, fixedSalaryRow, payDateRow])

        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
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
        default:
            break
        }
    }

    // MARK: - FieldRowViewDelegate

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        if row === payDateRow {
            delegate?.didTapPayDateRow()
        }
    }

    // MARK: - Public API

    func updateTypeValue(_ value: String) {
        typeRow.updateValue(value)
    }

    func updateCalcValue(_ value: String) {
        calcRow.updateValue(value)
    }

    func updateFixedSalaryValue(_ value: String) {
        fixedSalaryRow.updateValue(value)
    }

    func updatePayDateValue(_ value: String) {
        payDateRow.updateValue(value)
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

    func getPayDateValue() -> String {
        return payDateRow.getData()
    }
}
