//
//  UIStackView+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
