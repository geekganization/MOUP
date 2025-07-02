//
//  OnboardingViewController.swift
//  Routory
//
//  Created by 서동환 on 7/1/25.
//

import UIKit

import RxCocoa
import RxSwift

final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: OnboardingVCDelegate?
    
    private let disposeBag = DisposeBag()
    
    private let mode: OnboardingMode
    
    // MARK: - UI Components
    
    private let onboardingView: OnboardingView
    
    // MARK: - Initalizer
    
    init(mode: OnboardingMode) {
        self.mode = mode
        self.onboardingView = OnboardingView(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = onboardingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.onboardingVCWillDisappear()
    }
}

// MARK: - UI Methods

private extension OnboardingViewController {
    func configure() {
        setStyles()
        setBindings()
    }
    
    func setStyles() {
        self.view.backgroundColor = .clear
    }
    
    func setBindings() {
        onboardingView.getCloseButton.rx.tap
            .subscribe(with: self) { owner, _ in
                switch owner.mode {
                case .home:
                    break
                case .calendar:
                    OnboardingManager.hasSeenOnboardingCalendar = true
                }
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
}
