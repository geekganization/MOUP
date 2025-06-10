//
//  FieldRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class FieldRowView: UIView {

    init(title: String, value: String?, showDot: Bool = false, showSeparator: Bool = true) {
        super.init(frame: .zero)
        setup(title: title, value: value, showDot: showDot, showSeparator: showSeparator)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String, value: String?, showDot: Bool, showSeparator: Bool) {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .black
        }

        let dotView = UIView().then {
            $0.backgroundColor = .systemRed
            $0.layer.cornerRadius = 4
            $0.isHidden = !showDot
        }

        let valueLabel = UILabel().then {
            $0.text = value
            $0.textColor = .systemGray
            $0.font = .systemFont(ofSize: 16)
        }

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right")).then {
            $0.tintColor = .systemGray3
            $0.contentMode = .scaleAspectFit
        }

        addSubview(titleLabel)
        addSubview(dotView)
        addSubview(valueLabel)
        addSubview(arrow)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        dotView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(8)
        }

        arrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 8, height: 14))
        }

        valueLabel.snp.makeConstraints {
            $0.trailing.equalTo(arrow.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(44)
        }

        if showSeparator {
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
    }
}
