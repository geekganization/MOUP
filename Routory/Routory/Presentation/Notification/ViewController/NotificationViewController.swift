//
//  NotificationViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit

class NotificationViewController: UIViewController {
    // MARK: - Properties
    private let notificationView = NotificationView()

    override func loadView() {
        view = notificationView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension NotificationViewController {
    func configure() {
        setStyles()
        setBindings()
    }

    func setStyles() {
        view.backgroundColor = .yellow
    }

    func setBindings() {

    }
}
