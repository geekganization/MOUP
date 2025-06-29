//
//  WorkTimeView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol

protocol WorkTimeViewDelegate: AnyObject {
    func workTimeViewDidRequestTimePicker(for type: WorkTimeView.TimeType, current: String)
    func workTimeViewDidRequestBreakTimePicker(current: String)
}

// MARK: - WorkTimeView

final class WorkTimeView: UIView, FieldRowViewDelegate {

    // MARK: - Nested Types

    enum TimeType {
        case start, end
    }

    // MARK: - Properties

    weak var delegate: WorkTimeViewDelegate?

    private let startRow: FieldRowView
    private let endRow: FieldRowView
    private let restRow: FieldRowView
    private let titleLabel = UILabel()

    // MARK: - Initializers

    init(startTime: String, endTime: String, restTime: String) {
        self.startRow = FieldRowView(title: "출근", value: startTime)
        self.endRow = FieldRowView(title: "퇴근", value: endTime)
        self.restRow = FieldRowView(title: "휴게", value: restTime)
        super.init(frame: .zero)
        titleLabel.attributedText = makeTitleAttributedString(from: "근무시간 *")
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        [startRow, endRow, restRow].forEach { $0.delegate = self }

        let box = makeBoxedStackView(with: [startRow, endRow, restRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - FieldRowViewDelegate

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        switch row {
        case startRow:
            delegate?.workTimeViewDidRequestTimePicker(for: .start, current: startRow.getData())
        case endRow:
            delegate?.workTimeViewDidRequestTimePicker(for: .end, current: endRow.getData())
        case restRow:
            delegate?.workTimeViewDidRequestBreakTimePicker(current: restRow.getData())
        default:
            break
        }
    }

    // MARK: - Public API

    func updateValue(for type: TimeType, newValue: String) {
        switch type {
        case .start:
            startRow.updateValue(newValue)
        case .end:
            endRow.updateValue(newValue)
        }
    }

    func updateRestValue(_ newValue: String) {
        restRow.updateValue(newValue)
    }

    func getstartRowData() -> String { startRow.getData() }
    func getendRowData() -> String { endRow.getData() }
    func getrestRowData() -> String { restRow.getData() }
    
    func setIsRead() {
        startRow.setIsRead()
        endRow.setIsRead()
        restRow.setIsRead()
    }
    
    func setIsEditable() {
        startRow.setIsEditable()
        endRow.setIsEditable()
        restRow.setIsEditable()
    }
}
