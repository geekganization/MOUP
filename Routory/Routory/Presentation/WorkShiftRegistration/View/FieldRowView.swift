//
//  FieldRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

protocol FieldRowViewDelegate: AnyObject {
    func fieldRowViewDidTapChevron(_ row: FieldRowView)
}

final class FieldRowView: UIView {

    weak var delegate: FieldRowViewDelegate?

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
    }

    private let dotView = UIView().then {
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 4
        $0.isHidden = true
    }

    private let valueLabel = UILabel().then {
        $0.textColor = .systemGray
        $0.font = .systemFont(ofSize: 16)
    }

    private let arrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .systemGray3
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }

    init(title: String, value: String?, showDot: Bool = false) {
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

    private func setupLayout() {
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

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleChevronTap))
        arrow.addGestureRecognizer(tap)
    }

    @objc private func handleChevronTap() {
        delegate?.fieldRowViewDidTapChevron(self)
    }
    
    func updateTitle(_ name: String) {
        titleLabel.text = name
    }
}
