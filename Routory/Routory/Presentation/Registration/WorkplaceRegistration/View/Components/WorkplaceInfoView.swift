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

    private let nameRow = ValueRowView(title: "이름", value: nil)
    private let categoryRow = ValueRowView(title: "카테고리", value: nil)
    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
    }

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.attributedText = makeTitleAttributedString(from: title)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        nameRow.delegate = self
        categoryRow.delegate = self

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
    
    /// 이름 및 카테고리 항목을 비활성화하여 사용자 입력을 막습니다.
    /// - 텍스트 영역을 터치할 수 없도록 하고, 우측 화살표 아이콘도 숨깁니다.
    func disableEditing() {
        nameRow.isUserInteractionEnabled = false
        nameRow.updateArrowHidden(true)
        categoryRow.isUserInteractionEnabled = false
        categoryRow.updateArrowHidden(true)
    }
}
