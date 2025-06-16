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

func makeTitleAttributedString(from title: String) -> NSAttributedString {
    let fullText = title
    let attributed = NSMutableAttributedString(string: fullText)

    let fullRange = NSRange(location: 0, length: attributed.length)
    attributed.addAttribute(.font, value: UIFont.headBold(18), range: fullRange)
    attributed.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)

    if let starRange = fullText.range(of: "*") {
        let nsRange = NSRange(starRange, in: fullText)
        attributed.addAttribute(.foregroundColor, value: UIColor.primary500, range: nsRange)
    }

    return attributed
}

func parseDateComponents(from dateString: String) -> (year: Int, month: Int, day: Int)? {
    let components = dateString.split(separator: ".").map { String($0) }
    guard components.count == 3,
          let year = Int(components[0]),
          let month = Int(components[1]),
          let day = Int(components[2]) else {
        return nil
    }
    return (year, month, day)
}

func parseCurrencyStringToInt(_ value: String) -> Int {
    let cleaned = value.replacingOccurrences(of: ",", with: "")
    return Int(cleaned) ?? 0
}

func parseDateStringToInt(_ value: String) -> Int {
    let digitsOnly = value.trimmingCharacters(in: CharacterSet(charactersIn: "일")).trimmingCharacters(in: .whitespaces)
    return Int(digitsOnly) ?? 1
}
