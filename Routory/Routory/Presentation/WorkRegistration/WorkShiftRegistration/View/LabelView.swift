//
//  LabelView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol

protocol LabelViewDelegate: AnyObject {
    func labelViewDidTapSelectColor(_ sender: LabelView)
}

// MARK: - LabelView

final class LabelView: UIView, ValueRowViewDelegate {

    // MARK: - Properties

    weak var delegate: LabelViewDelegate?

    private let redLabelRow = ValueRowView(title: "빨간색", value: nil, showDot: true)

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
        redLabelRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "라벨"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        let box = makeBoxedStackView(with: [redLabelRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - ValueRowViewDelegate

    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        delegate?.labelViewDidTapSelectColor(self)
    }

    // MARK: - Public API

    func updateLabelName(_ name: String, color: UIColor) {
        redLabelRow.updateTitle(name)
        redLabelRow.updateDotColor(color)
    }

    func getData() -> String {
        return redLabelRow.getData()
    }

    func getColorLabelData() -> String {
        return redLabelRow.getColorLabelData()
    }

    func getColorData() -> UIColor {
        return redLabelRow.getColorData()
    }
}
