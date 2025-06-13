//
//  WorkerSelectionView.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit
import Then

protocol WorkerSelectionViewDelegate: AnyObject {
    func workerSelectionViewDidTap()
}

final class WorkerSelectionView: UIView, ValueRowViewDelegate {

    weak var delegate: WorkerSelectionViewDelegate?

    private let selectRow = ValueRowView(title: "인원 선택", value: nil)
    private let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)
        titleLabel.attributedText = makeTitleAttributedString(from: "근무자 *")
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectRow.delegate = self

        let box = makeBoxedStackView(with: [selectRow])

        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - Delegate

    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        delegate?.workerSelectionViewDidTap()
    }

    // MARK: - Public API

    func updateSelectedTitle(_ title: String) {
        selectRow.updateTitle(title)
    }
    
    func updateSelectedValue(_ value: String) {
        selectRow.updateValue(value)
    }
    
    func updateSelectedEmployees(_ employees: [Employee]) {
        selectRow.updateEmployeesData(employees)
    }

    func getSelectedWorkerData() -> [Employee] {
        return selectRow.getEmployeesData()
    }
}
