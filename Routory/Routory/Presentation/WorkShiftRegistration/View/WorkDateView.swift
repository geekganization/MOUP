//
//  WorkDateView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkDateView: UIView, FieldRowViewDelegate, ValueRowViewDelegate {

    weak var parentViewController: UIViewController?

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
        showDatePicker()
    }
    
    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        print("반복 클릭")
    }

    private func showDatePicker() {
        let alert = UIAlertController(title: "날짜 선택", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)

        let datePicker = UIDatePicker().then {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .wheels
            $0.frame = CGRect(x: 0, y: 30, width: alert.view.bounds.width - 20, height: 160)
        }

        alert.view.addSubview(datePicker)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let dateString = formatter.string(from: datePicker.date)
            self?.dateRow.updateValue(dateString)
        }))

        parentViewController?.present(alert, animated: true)
    }
    
    func getdateRowData() -> String {
        return dateRow.getData()
    }
    
    func getrepeatRowData() -> String {
        return repeatRow.getData()
    }
}
