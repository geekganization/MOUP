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

    private let maxLength = 50
    private let placeholder: String

    // MARK: - UI Components

    let textView = UITextView()
    private let counterLabel = UILabel()
    private let textContainerView = UIView()

    // MARK: - Initializers

    init(placeholder: String) {
        self.placeholder = placeholder
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
            $0.font = .headBold(18)
        }
        
        textView.do {
            $0.font = .fieldsRegular(16)
            $0.text = placeholder
            $0.textColor = .gray400
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.delegate = self
            $0.isScrollEnabled = true
            $0.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
            $0.textContainer.lineFragmentPadding = 0
            $0.returnKeyType = .done
        }

        counterLabel.do {
            $0.text = "0/\(maxLength)"
            $0.font = .fieldsRegular(14)
            $0.textColor = .gray600
        }

        textContainerView.addSubview(textView)
        textContainerView.addSubview(counterLabel)

        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(100)
        }

        counterLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        addArrangedSubview(title)
        addArrangedSubview(textContainerView)
    }

    // MARK: - Public API

    func getData() -> String {
        return textView.textColor == .gray400 ? "" : textView.text
    }
}

// MARK: - UITextViewDelegate

extension MemoBoxView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray400 {
            textView.text = nil
            textView.textColor = .gray900
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = .gray400
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false                  
        }
        return true
    }
}
