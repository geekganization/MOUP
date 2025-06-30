//
//  BasePickerViewController.swift
//  Routory
//
//  Created by 서동환 on 7/1/25.
//

import UIKit

final class BasePickerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let mode: PickerMode
    
    // MARK: - UI Components
    
    private let basePickerView: BasePickerView
    
    // MARK: - Initializer
    
    init(mode: PickerMode, focusedYear: Int? = nil, focusedMonth: Int? = nil, focusedDay: Int? = nil) {
        self.mode = mode
        self.basePickerView = BasePickerView(mode: mode,
                                             focusedYear: focusedYear,
                                             focusedMonth: focusedMonth,
                                             focusedDay: focusedDay)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = basePickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - UI Methods

private extension BasePickerViewController {
    func configure() {
        setStyles()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
}
