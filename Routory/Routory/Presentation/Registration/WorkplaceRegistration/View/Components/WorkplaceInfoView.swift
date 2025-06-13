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
}

final class WorkplaceInfoView: UIView, ValueRowViewDelegate {

    weak var delegate: WorkplaceInfoViewDelegate?

    private let nameRow = ValueRowView(title: "이름", value: "세븐일레븐 동탄제일점")
    private let categoryRow = ValueRowView(title: "카테고리", value: "편의점")

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        nameRow.delegate = self
        categoryRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "근무지"
            $0.font = .headBold(18)
        }

        let box = makeBoxedStackView(with: [nameRow, categoryRow])

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
}
