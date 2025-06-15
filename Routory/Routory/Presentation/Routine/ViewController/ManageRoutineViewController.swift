//
//  ManageRoutineViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit

class ManageRoutineViewController: UIViewController {
    // MARK: - Properties
    private let manageRoutineView = ManageRoutineView()

    override func loadView() {
        view = manageRoutineView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

private extension ManageRoutineViewController {
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
