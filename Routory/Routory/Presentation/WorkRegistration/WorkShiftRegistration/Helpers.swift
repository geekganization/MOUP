//
//  Helpers.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit

func makeBoxedStackView(with views: [UIView]) -> UIStackView {
    return UIStackView(arrangedSubviews: views).then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
        $0.clipsToBounds = true
    }
}
