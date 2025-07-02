//
//  ShiftRegistrationActionHandler.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit

final class RegistrationActionHandler: NSObject {

    weak var contentView: UIView?
    weak var navigationController: UINavigationController?

    init(contentView: UIView, navigationController: UINavigationController?) {
        self.contentView = contentView
        self.navigationController = navigationController
    }

    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.6
        }
    }

    @objc func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }
}
