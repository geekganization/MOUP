//
//  ColorSelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Model

struct LabelColor {
    let name: String
    let color: UIColor
}

// MARK: - ViewController

final class ColorSelectionViewController: UIViewController {

    // MARK: - Properties

    private let colors: [LabelColor] = [
        LabelColor(name: "빨간색", color: UIColor(red: 1, green: 0.18, blue: 0.33, alpha: 1)),
        LabelColor(name: "주황색", color: UIColor(red: 1, green: 0.58, blue: 0, alpha: 1)),
        LabelColor(name: "노란색", color: UIColor(red: 1, green: 0.8, blue: 0, alpha: 1)),
        LabelColor(name: "초록색", color: UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1)),
        LabelColor(name: "파란색", color: UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)),
        LabelColor(name: "보라색", color: UIColor(red: 0.69, green: 0.32, blue: 0.87, alpha: 1)),
        LabelColor(name: "갈색", color: UIColor(red: 0.64, green: 0.52, blue: 0.37, alpha: 1))
    ]

    private var selectedIndex: Int = 0
    var onSelect: ((LabelColor) -> Void)?

    // MARK: - UI Components

    private let tableView = UITableView().then {
        $0.register(ColorCell.self, forCellReuseIdentifier: "ColorCell")
        $0.rowHeight = 48
        $0.tableFooterView = UIView()
    }

    private let applyButton = UIButton(type: .system).then {
        $0.setTitle("적용하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .white
        title = "색상 선택"
        view.addSubview(tableView)
        view.addSubview(applyButton)

        tableView.dataSource = self
        tableView.delegate = self

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    // MARK: - Layout

    private func layout() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        applyButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(52)
        }
    }

    // MARK: - Actions

    @objc private func didTapApply() {
        let selectedColor = colors[selectedIndex]
        onSelect?(selectedColor)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ColorSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        colors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
            return UITableViewCell()
        }

        let color = colors[indexPath.row]
        cell.configure(name: color.name, color: color.color, isSelected: indexPath.row == selectedIndex)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
}
