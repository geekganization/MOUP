//
//  UIView+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
