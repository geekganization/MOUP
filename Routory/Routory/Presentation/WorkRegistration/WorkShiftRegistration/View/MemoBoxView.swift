//
//  MemoBoxView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - MemoBoxView

final class MemoBoxView: UIStackView {

    // MARK: - Constants

    private let placeholder = "내용을 입력하세요."
    private let maxLength = 150

    // MARK: - UI Components

    let textView = UITextView()
    let counterLabel = UILabel()

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let title = UILabel().then {
            $0.text = "메모"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        textView.do {
            $0.font = .systemFont(ofSize: 14)
            $0.text = placeholder
            $0.textColor = .lightGray
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.isScrollEnabled = false
            $0.delegate = self
        }

        counterLabel.do {
            $0.text = "0/\(maxLength)"
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .systemGray
            $0.textAlignment = .right
        }

        textView.snp.makeConstraints {
            $0.height.equalTo(100)
        }

        addArrangedSubview(title)
        addArrangedSubview(textView)
        addArrangedSubview(counterLabel)
    }

    // MARK: - Public API

    func getData() -> String {
        return textView.textColor == .lightGray ? "" : textView.text
    }
}

// MARK: - UITextViewDelegate

extension MemoBoxView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        counterLabel.text = "\(count)/\(maxLength)"

        if count > maxLength {
            textView.text = String(textView.text.prefix(maxLength))
            counterLabel.text = "\(maxLength)/\(maxLength)"
        }
    }
}
