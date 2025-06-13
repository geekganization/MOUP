//
//  FieldRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol

protocol FieldRowViewDelegate: AnyObject {
    func fieldRowViewDidTapChevron(_ row: FieldRowView)
}

// MARK: - FieldRowView

final class FieldRowView: UIView {

    // MARK: - Properties

    weak var delegate: FieldRowViewDelegate?
    private let withBackground: Bool

    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let dotView = UIView().then {
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 4
        $0.isHidden = true
    }

    private let valueContainerView = UIView().then {
        $0.layer.cornerRadius = 10
    }

    private let valueLabel = UILabel().then {
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
        $0.isUserInteractionEnabled = true
    }

    // MARK: - Initializer

    init(title: String, value: String?, showDot: Bool = false, withBackground: Bool = true) {
        self.withBackground = withBackground
        super.init(frame: .zero)
        titleLabel.text = title
        valueLabel.text = value
        dotView.isHidden = !showDot
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        // 배경색 조건 적용
        valueContainerView.backgroundColor = withBackground ? .primary100 : .clear

        addSubview(titleLabel)
        addSubview(dotView)
        addSubview(valueContainerView)
        valueContainerView.addSubview(valueLabel)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        dotView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(8)
        }

        valueContainerView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
            $0.leading.greaterThanOrEqualTo(dotView.snp.trailing).offset(8)
        }

        valueLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }

        snp.makeConstraints {
            $0.height.equalTo(44)
        }

        let separator = UIView().then {
            $0.backgroundColor = UIColor.systemGray5
        }

        addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    // MARK: - Gesture

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleValueTap))
        valueLabel.addGestureRecognizer(tap)
    }

    @objc private func handleValueTap() {
        delegate?.fieldRowViewDidTapChevron(self)
    }

    // MARK: - Public API

    func updateTitle(_ name: String) {
        titleLabel.text = name
    }

    func updateValue(_ name: String) {
        valueLabel.text = name
    }

    func getData() -> String {
        return valueLabel.text ?? ""
    }
}
