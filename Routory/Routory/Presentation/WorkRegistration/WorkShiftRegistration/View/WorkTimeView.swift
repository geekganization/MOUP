//
//  WorkTimeView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkTimeView: UIView, FieldRowViewDelegate {

    private let startRow = FieldRowView(title: "출근", value: "09:00")
    private let endRow = FieldRowView(title: "퇴근", value: "18:00")
    private let restRow = FieldRowView(title: "휴게", value: "1시간")
        
    private weak var presentingVC: UIViewController?

     init(presentingViewController: UIViewController) {
         self.presentingVC = presentingViewController
         super.init(frame: .zero)
         setup()
     }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        [startRow, endRow, restRow].forEach { $0.delegate = self }

        let titleLabel = UILabel().then {
            $0.text = "근무시간"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [startRow, endRow, restRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func fieldRowViewDidTapChevron(_ row: FieldRowView) {
        switch row {
        case startRow:
            showTimePicker(for: startRow)
        case endRow:
            showTimePicker(for: endRow)
        case restRow:
            showBreakTimePicker(for: restRow)
        default: break
        }
    }
    
    private func showTimePicker(for row: FieldRowView) {
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")

        alert.view.addSubview(picker)
        picker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: picker.date)
            row.updateValue(timeString)
        }))

        presentingVC?.present(alert, animated: true, completion: nil)
    }
    
    private func showBreakTimePicker(for row: FieldRowView) {
        let vc = BreakTimePickerViewController()
        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        vc.onSelect = { [weak self] index in
            let minutes = (index + 1) * 30
            let hour = minutes / 60
            let minute = minutes % 60
            let text = hour > 0 ? "\(hour)시간\(minute > 0 ? " \(minute)분" : "")" : "\(minute)분"
            row.updateValue(text)
        }

        presentingVC?.present(vc, animated: true)
    }
    
    func getstartRowData() -> String {
        return startRow.getData()
    }
    
    func getendRowData() -> String {
        return endRow.getData()
    }
    
    func getrestRowData() -> String {
        return restRow.getData()
    }

}
