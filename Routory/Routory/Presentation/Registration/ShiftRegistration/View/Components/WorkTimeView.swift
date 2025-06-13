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

    private let startRow = FieldRowView(title: "출근", value: "09:00")
    private let endRow = FieldRowView(title: "퇴근", value: "18:00")
    private let restRow = FieldRowView(title: "휴게", value: "1시간")

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        [startRow, endRow, restRow].forEach { $0.delegate = self }

        let titleLabel = UILabel().then {
            let fullText = "근무시간 *"
            let font = UIFont.headBold(18)
            
            let attributedString = NSMutableAttributedString(string: fullText, attributes: [
                .font: font,
                .foregroundColor: UIColor.label
            ])
            
            if let range = fullText.range(of: "*") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.primary500, range: nsRange)
            }
            
            $0.attributedText = attributedString
            $0.numberOfLines = 1
        }

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
}
