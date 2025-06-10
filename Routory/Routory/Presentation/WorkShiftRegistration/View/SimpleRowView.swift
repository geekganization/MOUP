//
//  SimpleRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class SimpleRowView: UIView {

    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String) {
        let label = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }

        addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
