//
//  BreakTimePickerViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit

final class BreakTimePickerViewController: UIViewController {

    private let pickerView = UIPickerView()
    private let confirmButton = UIButton(type: .system)

    var onSelect: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        pickerView.dataSource = self
        pickerView.delegate = self

        confirmButton.setTitle("확인", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
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

    @objc private func confirmTapped() {
        let index = pickerView.selectedRow(inComponent: 0)
        dismiss(animated: true) {
            self.onSelect?(index)
        }
    }
}

extension BreakTimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        6 
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let minutes = (row + 1) * 30
        let hour = minutes / 60
        let min = minutes % 60
        return hour > 0 ? "\(hour)시간\(min > 0 ? " \(min)분" : "")" : "\(min)분"
    }
}
