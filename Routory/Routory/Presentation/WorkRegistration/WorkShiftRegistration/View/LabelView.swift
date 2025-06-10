//
//  LabelView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

protocol LabelViewDelegate: AnyObject {
    func labelViewDidTapSelectColor(_ sender: LabelView)
}

final class LabelView: UIView, ValueRowViewDelegate {

    weak var delegate: LabelViewDelegate?

    private let redLabelRow = ValueRowView(title: "빨간색", value: nil, showDot: true)

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        delegate?.labelViewDidTapSelectColor(self)
    }

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
