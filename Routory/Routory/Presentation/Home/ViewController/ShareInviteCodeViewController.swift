//
//  ShareInviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/19/25.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class ShareInviteCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let inviteCode: String
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    
    private let shareInviteCodeView = ShareInviteCodeView().then {
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
    
    // MARK: - Initializer
    
    init(inviteCode: String) {
        self.inviteCode = inviteCode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ShareInviteCodeViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(shareInviteCodeView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
        shareInviteCodeView.update(inviteCode: inviteCode)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        shareInviteCodeView.snp.makeConstraints {
            $0.height.equalTo(249)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    // MARK: - setActions
    func setActions() {
        shareInviteCodeView.onDismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        shareInviteCodeView.copyInviteCodeButtonView.rx.tap
            .bind { [weak self] in
                guard let inviteCode = self?.inviteCode else { return }
                UIPasteboard.general.string = inviteCode
                self?.showAlert()
            }
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundDidTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 임시로 alert로 해두었습니다.
    func showAlert(title: String = "복사 완료", message: String = "초대 코드가 클립보드에 복사되었어요.") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc func backgroundDidTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if shareInviteCodeView.frame.contains(location) == false {
            dismiss(animated: true)
        }
    }
}
