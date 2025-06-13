//
//  AmountInputViewController.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class TextInputViewController: UIViewController {

    // MARK: - Public Props

    var onComplete: ((String) -> Void)?

    // MARK: - Private

    private let titleText: String
    private let descriptionText: String
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let formatter: ((String) -> String)?
    private let validator: ((String) -> Bool)?   

    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)

    // MARK: - Initializer

    init(
        title: String,
        description: String,
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> Bool)? = nil
    ) {
        self.titleText = title
        self.descriptionText = description
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.formatter = formatter
        self.validator = validator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
    }

    private func setupNavigationBar() {
        title = titleText
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        navigationItem.leftBarButtonItem?.tintColor = .gray700
    }

    private func setupUI() {
        view.backgroundColor = .white

        let guideLabel = UILabel().then {
            $0.text = descriptionText
            $0.font = .bodyMedium(16)
            $0.textColor = .gray900
        }

        textField.do {
            $0.font = .bodyMedium(16)
            $0.keyboardType = keyboardType
            $0.textAlignment = .left
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.placeholder = placeholder
            $0.setLeftPadding(12)
            $0.setRightPadding(12)
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }

        doneButton.do {
            $0.setTitle("완료", for: .normal)
            $0.titleLabel?.font = .buttonSemibold(18)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .primary500
            $0.layer.cornerRadius = 12
            $0.isEnabled = false
            $0.alpha = 0.5
            $0.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        }

        view.addSubview(guideLabel)
        view.addSubview(textField)
        view.addSubview(doneButton)

        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        doneButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(52)
        }
    }

    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        guard var text = textField.text else { return }

        if let formatter = formatter {
            let raw = text.replacingOccurrences(of: ",", with: "")
            text = formatter(raw)
            textField.text = text

            let end = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: end, to: end)
        }

        let isValid = validator?(text) ?? !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        doneButton.isEnabled = isValid
        doneButton.alpha = isValid ? 1.0 : 0.5
    }

    @objc private func didTapDone() {
        guard let text = textField.text else { return }
        onComplete?(text)
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
