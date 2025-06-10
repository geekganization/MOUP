//
//  MemoBoxView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class MemoBoxView: UIStackView {

    let textView = UITextView()
    let counterLabel = UILabel()

    init() {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let title = UILabel().then {
            $0.text = "메모"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        textView.do {
            $0.font = .systemFont(ofSize: 14)
            $0.text = "내용을 입력하세요."
            $0.textColor = .lightGray
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.isScrollEnabled = false
        }

        counterLabel.do {
            $0.text = "0/150"
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
    
    func getData() -> String {
        return textView.text ?? ""
    }
}
