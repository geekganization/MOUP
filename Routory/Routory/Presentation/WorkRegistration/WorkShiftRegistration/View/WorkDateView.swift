//
//  WorkDateView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

protocol WorkDateViewDelegate: AnyObject {
    func didTapDateRow(completion: @escaping (Date) -> Void)
    func didTapRepeatRow(from view: WorkDateView)
}

final class WorkDateView: UIView, FieldRowViewDelegate, ValueRowViewDelegate {

    weak var delegate: WorkDateViewDelegate?

    private let dateRow = FieldRowView(title: "날짜", value: "2025.07.07")
    private let repeatRow = ValueRowView(title: "반복", value: "없음")

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        dateRow.delegate = self
        repeatRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "근무 날짜"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [dateRow, repeatRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        delegate?.didTapDateRow { [weak self] selectedDate in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let dateString = formatter.string(from: selectedDate)
            self?.dateRow.updateValue(dateString)
        }
    }
    
    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        delegate?.didTapRepeatRow(from: self)
    }
    
    func updateRepeatValue(_ value: String) {
        repeatRow.updateValue(value)
    }
    
    func getdateRowData() -> String {
        return dateRow.getData()
    }
    
    func getrepeatRowData() -> String {
        return repeatRow.getData()
    }
}
