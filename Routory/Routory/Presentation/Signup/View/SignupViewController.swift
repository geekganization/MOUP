//
//  SignupViewController.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit

class SignupViewController: UIViewController {
    
    // MARK: - View / ViewModel
    private let signUpView = SignupView()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func loadView() {
        self.view = signUpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

}
