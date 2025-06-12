//
//  Helpers.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit

// MARK: - Utility Functions

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

func configureShiftNavigationBar(
    for viewController: UIViewController,
    title: String,
    target: Any,
    action: Selector
) {
    viewController.title = title
    let backButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.left"),
        style: .plain,
        target: target,
        action: action
    )
    backButton.tintColor = .gray700
    viewController.navigationItem.leftBarButtonItem = backButton
}
