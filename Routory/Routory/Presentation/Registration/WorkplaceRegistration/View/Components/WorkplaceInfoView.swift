//
//  WorkplaceInfoView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit

protocol WorkplaceInfoViewDelegate: AnyObject {
    func didTapNameRow()
    func didTapCategoryRow()
    func didTapWorkerManagerRow(workplaceId: String)
}

final class WorkplaceInfoView: UIView, ValueRowViewDelegate {

    weak var delegate: WorkplaceInfoViewDelegate?

    private let nameRow: ValueRowView
    private let categoryRow: ValueRowView
    private let workerManagerRow: ValueRowView
    private let workplaceId: String
    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
    }

    init(nameValue: String?, categoryValue: String?, workplaceId: String) {
        self.nameRow = ValueRowView(title: "이름", value: nameValue)
        self.categoryRow = ValueRowView(title: "카테고리", value: categoryValue)
        self.workerManagerRow = ValueRowView(title: "알바생 관리", value: nil)
        self.workplaceId = workplaceId
        super.init(frame: .zero)
        titleLabel.attributedText = makeTitleAttributedString(from: "근무지 *")
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        nameRow.delegate = self
        categoryRow.delegate = self
        workerManagerRow.delegate = self

        let box = makeBoxedStackView(with: [nameRow, categoryRow,workerManagerRow])

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
        case nameRow:
            delegate?.didTapNameRow()
        case categoryRow:
            delegate?.didTapCategoryRow()
        case workerManagerRow:
            delegate?.didTapWorkerManagerRow(workplaceId: workplaceId)
        default:
            break
        }
    }

    // MARK: - Public API

    func updateName(_ value: String) {
        nameRow.updateValue(value)
    }

    func updateCategory(_ value: String) {
        categoryRow.updateValue(value)
    }

    func getName() -> String {
        return nameRow.getValueData()
    }

    func getCategory() -> String {
        return categoryRow.getValueData()
    }

    func disableEditing() {
        nameRow.isUserInteractionEnabled = false
        nameRow.updateArrowHidden(true)
        categoryRow.isUserInteractionEnabled = false
        categoryRow.updateArrowHidden(true)
    }
    
    func enableEditing() {
        nameRow.isUserInteractionEnabled = true
        nameRow.updateArrowHidden(false)
        categoryRow.isUserInteractionEnabled = true
        categoryRow.updateArrowHidden(false)
    }
    
    func hideWorkerManagerRow() {
        workerManagerRow.isHidden = true
    }

    func showWorkerManagerRow() {
        workerManagerRow.isHidden = false
    }
}
