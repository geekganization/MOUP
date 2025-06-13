//
//  WorkplaceAddViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/13/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceAddViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let workplaceAddView = WorkplaceAddView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.layer.masksToBounds = true
        $0.backgroundColor = .white
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension WorkplaceAddViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(workplaceAddView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .background
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workplaceAddView.snp.makeConstraints {
            $0.height.equalTo(227)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
