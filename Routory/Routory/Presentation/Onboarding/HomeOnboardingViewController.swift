//
//  HomeOnboardingViewController.swift
//  Routory
//
//  Created by 송규섭 on 7/1/25.
//

import UIKit

class HomeOnboardingViewController: UIViewController {

    private let userType: UserType

    private lazy var onboardingImageView = UIImageView().then {
        $0.image = userType == .worker ? .onboardingWorkerHome : .onboardingOwnerHome
    }

    private let closeButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .xMark.withTintColor(.white, renderingMode: .alwaysOriginal)
        config.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)

        $0.configuration = config
    }

    init(userType: UserType) {
        self.userType = userType
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension HomeOnboardingViewController {
    func configure() {
        setHierarchy()
        setConstraints()
        setAction()
    }

    func setHierarchy() {
        view.addSubviews(onboardingImageView, closeButton)
    }

    func setConstraints() {
        onboardingImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(48)
            $0.leading.equalToSuperview().inset(4)
            $0.size.equalTo(44)
        }
    }

    func setAction() {
        closeButton.addTarget(self, action: #selector(didTapCloseBtn), for: .touchUpInside)
    }

    @objc func didTapCloseBtn() {
        self.dismiss(animated: false) {
            OnboardingManager.hasSeenOnboardingHome = true
        }
    }
}
