//
//  ReusablePickerViewController.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit

final class ReusablePickerViewController: UIViewController {

    // MARK: - Types

    typealias PickerData = [[String]]
    typealias PickerSelectionHandler = ([Int]) -> Void

    // MARK: - UI Components

    private let pickerView = UIPickerView()
    private let confirmButton = UIButton(type: .system)

    // MARK: - Properties

    private let data: PickerData
    var onSelect: PickerSelectionHandler

    // MARK: - Init

    init(data: PickerData, onSelect: @escaping PickerSelectionHandler) {
        self.data = data
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        pickerView.dataSource = self
        pickerView.delegate = self

        confirmButton.setTitle("확인", for: .normal)
        confirmButton.titleLabel?.font = .buttonSemibold(16)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        view.addSubview(pickerView)
        view.addSubview(confirmButton)

        pickerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        let selectedIndexes = (0..<data.count).map {
            pickerView.selectedRow(inComponent: $0)
        }
        dismiss(animated: true) {
            self.onSelect(selectedIndexes)
        }
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate

extension ReusablePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        data.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        data[component].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        data[component][row]
    }
}
