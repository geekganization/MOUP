//
//  WorkDateView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol

protocol WorkDateViewDelegate: AnyObject {
    func didTapDateRow(completion: @escaping (Date) -> Void)
    func didTapRepeatRow(from view: WorkDateView)
}

// MARK: - WorkDateView

final class WorkDateView: UIView, FieldRowViewDelegate, ValueRowViewDelegate {

    // MARK: - Properties

    weak var delegate: WorkDateViewDelegate?
    private var repeatDays: [String] = []

    private let dateRow: FieldRowView
    private let repeatRow: ValueRowView
    private let titleLabel = UILabel()

    // MARK: - Initializer

    init(dateValue: String, repeatValue: String) {
        self.dateRow = FieldRowView(title: "날짜", value: dateValue)
        self.repeatRow = ValueRowView(title: "반복", value: repeatValue)
        super.init(frame: .zero)
        titleLabel.attributedText = makeTitleAttributedString(from: "근무 날짜 *")
        setup()
        hiddenRepeatRow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        dateRow.delegate = self
        repeatRow.delegate = self

        let box = makeBoxedStackView(with: [dateRow, repeatRow])

        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - FieldRowViewDelegate

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        delegate?.didTapDateRow { [weak self] selectedDate in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let dateString = formatter.string(from: selectedDate)
            self?.dateRow.updateValue(dateString)
        }
    }

    // MARK: - ValueRowViewDelegate

    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        delegate?.didTapRepeatRow(from: self)
    }

    // MARK: - Public API
    
    func updateRepeatData(_ data: [String]) {
        repeatDays = data
    }

    func getRepeatData() -> [String] {
        return repeatDays
    }
    
    func hiddenRepeatRow() {
        repeatRow.isHidden = true
    }

    func updateRepeatValue(_ value: String) {
        repeatRow.updateValue(value)
    }

    func getdateRowData() -> String {
        return dateRow.getData()
    }

    func getrepeatRowData() -> String {
        return repeatRow.getValueData()
    }
    
    func setIsRead() {
        dateRow.setIsRead()
        repeatRow.updateArrowHidden(true)
    }
    
    func setIsEditable() {
        dateRow.setIsEditable()
        repeatRow.updateArrowHidden(false)
    }
}
