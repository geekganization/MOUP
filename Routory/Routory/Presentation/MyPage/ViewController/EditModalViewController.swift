//
//  EditModalViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/12/25.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class EditModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private var bottomConstraint: Constraint?
    private let saveButtonDidTapSubject = PublishSubject<Void>()
    private let viewModel: EditModalViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let editModal = EditModal().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage.xMark, for: .normal)
    }
    
    // MARK: - Initializer
    
    init(viewModel: EditModalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editModal.textFieldView.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        registerKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension EditModalViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBindings()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(
            closeButton,
            editModal
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        closeButton.snp.makeConstraints {
            $0.bottom.equalTo(editModal.snp.top)
            $0.trailing.equalTo(editModal.snp.trailing)
        }
        
        editModal.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(225)
            $0.width.equalTo(343)
            self.bottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        bottomConstraint?.update(inset: keyboardHeight)
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - setActions
    func setActions() {
        closeButton.addTarget(
            self,
            action: #selector(closeButtonDidTap),
            for: .touchUpInside
        )
        
        editModal.saveButtonView.addTarget(
            self,
            action: #selector(saveButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func closeButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc func saveButtonDidTap() {
        saveButtonDidTapSubject.onNext(())
    }
    
    // MARK: - setBindings
    func setBindings() {
        let input = EditModalViewModel.Input(
            textChanged: editModal.textFieldView.rx.text.orEmpty.asObservable(),
            saveButtonDidTap: saveButtonDidTapSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

//        output.saveCompleted
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] newNickname in
//                self?.onNicknameSaved?(newNickname)
//                self?.dismiss(animated: true)
//            })
//            .disposed(by: disposeBag)

        output.validationError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                let isValid = errorMessage.isEmpty
                self?.editModal.updateValidationMessage(
                    message: isValid ? "사용 가능한 닉네임이에요!" : errorMessage,
                    isValid: isValid
                )
            })
            .disposed(by: disposeBag)
    }
}
