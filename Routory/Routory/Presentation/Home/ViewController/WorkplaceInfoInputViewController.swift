//
//  WorkplaceInfoInputViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/28/25.
//

import UIKit

final class WorkplaceInfoInputViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let workplaceInfoInput = WorkplaceInfoInput()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        view = workplaceInfoInput
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
