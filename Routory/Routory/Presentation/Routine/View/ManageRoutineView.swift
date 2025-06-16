//
//  ManageRoutineView.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit

final class ManageRoutineView: UIView {
    // MARK: - Properties

    // MARK: - UI Components

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
}

private extension ManageRoutineView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {

    }

    // MARK: - setStyles
    func setStyles() {

    }

    // MARK: - setConstraints
    func setConstraints() {

    }
}

