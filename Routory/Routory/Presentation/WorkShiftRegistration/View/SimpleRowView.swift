//
//  SimpleRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

protocol SimpleRowViewDelegate: AnyObject {
    func simpleRowViewDidTapChevron(_ view: SimpleRowView)
}

final class SimpleRowView: UIView {

    weak var delegate: SimpleRowViewDelegate?

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }

    private let requiredMark = UILabel().then {
        $0.text = "*"
        $0.textColor = .systemRed
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .systemGray2
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }

    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.systemGray4
    }

    init(title: String, isRequired: Bool = false) {
        super.init(frame: .zero)
        titleLabel.text = title
        requiredMark.isHidden = !isRequired
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, requiredMark]).then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        addSubview(textStack)
        addSubview(chevronImageView)
        addSubview(separatorView)

        textStack.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(12)
            $0.height.equalTo(12)
        }

        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chevronTapped))
        chevronImageView.addGestureRecognizer(tap)
    }

    @objc private func chevronTapped() {
        delegate?.simpleRowViewDidTapChevron(self)
    }
}
