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

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "근무자"
            $0.font = .headBold(18)
        }

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

    func updateSelectedWorker(_ name: String) {
        selectRow.updateValue(name)
    }

    func getSelectedWorker() -> String {
        return selectRow.getData()
    }
}
