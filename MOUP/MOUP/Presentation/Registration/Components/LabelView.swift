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

    private let redLabelRow: ValueRowView

    // MARK: - Initializers

    init(
        title: String,
        value: String? = nil,
        showDot: Bool,
        dotColor: UIColor? = .systemRed
    ) {
        self.redLabelRow = ValueRowView(
            title: title,
            value: value,
            showDot: showDot,
            dotColor: dotColor
        )
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
            $0.font = .headBold(18)
            $0.textColor = .gray900
        }

        let box = makeBoxedStackView(with: [redLabelRow])
        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 12
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
        return redLabelRow.getValueData()
    }

    func getColorLabelData() -> String {
        return redLabelRow.getTitleData()
    }

    func getColorData() -> UIColor {
        return redLabelRow.getColorData()
    }
    
    func disableEditing() {
        redLabelRow.updateArrowHidden(true)
    }
    
    func enableEditing() {
        redLabelRow.updateArrowHidden(false)
    }
}
