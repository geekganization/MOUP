//
//  AlarmTimeFieldView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class AlarmTimeFieldView: UIView {

    private let label = UILabel().then {
        $0.text = "알림시간"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .label
    }

    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.tintColor = .systemGray2
        $0.contentMode = .scaleAspectFit
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = .white
        isUserInteractionEnabled = true

        addSubview(label)
        addSubview(chevron)

        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }

        chevron.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }

        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }

    func update(text: String) {
        label.text = text
    }
}
