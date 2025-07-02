//
//  AlarmTimeFieldView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - AlarmTimeFieldView

final class AlarmTimeFieldView: UIView {

    // MARK: - UI Components

    private let label = UILabel().then {
        $0.text = "알림시간"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    private func setup() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = .white
        isUserInteractionEnabled = true

        addSubview(label)

        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }

        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }

    // MARK: - Public Method

    func update(text: String) {
        label.text = text
    }
    
    func getLabel() -> String {
        return label.text ?? "00:00"
    }
}
