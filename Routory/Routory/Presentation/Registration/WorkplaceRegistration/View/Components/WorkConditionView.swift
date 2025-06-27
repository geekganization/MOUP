//
//  WorkConditionView.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class WorkConditionView: UIView {

    // MARK: - Constants

    private let items: [String]
    private let initialCheckedItems: [String: Bool]
    private let mainGroupItem: String
    private let subGroupItems: [String]
    private var checkBoxes: [UIButton] = []

    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
    }

    // MARK: - Initializer

    init(
        isFourMajorSelected: Bool,
        isNationalPensionSelected: Bool,
        isHealthInsuranceSelected: Bool,
        isEmploymentInsuranceSelected: Bool,
        isIndustrialAccidentInsuranceSelected: Bool,
        isIncomeTaxSelected: Bool,
        isWeeklyAllowanceSelected: Bool,
        isNightAllowanceSelected: Bool
    ) {
        self.items = [
            "4대 보험", "국민연금", "건강보험", "고용보험",
            "산재보험", "소득세", "야간수당*"
        ]

        self.initialCheckedItems = [
            "4대 보험": isFourMajorSelected,
            "국민연금": isNationalPensionSelected,
            "건강보험": isHealthInsuranceSelected,
            "고용보험": isEmploymentInsuranceSelected,
            "산재보험": isIndustrialAccidentInsuranceSelected,
            "소득세": isIncomeTaxSelected,
            "야간수당*": isNightAllowanceSelected
        ]

        self.mainGroupItem = "4대 보험"
        self.subGroupItems = ["국민연금", "건강보험", "고용보험", "산재보험"]

        super.init(frame: .zero)
        titleLabel.attributedText = makeTitleAttributedString(from: "근무조건 *")
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let boxView = UIView().then {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.clipsToBounds = true
        }

        let itemStack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 0
        }

        for (index, text) in items.enumerated() {
            let row = UIStackView().then {
                $0.axis = .horizontal
                $0.alignment = .center
                $0.distribution = .equalSpacing
            }

            let label = UILabel().then {
                $0.text = text
                $0.font = .bodyMedium(16)
                $0.textColor = .gray900
            }

            let checkbox = UIButton(type: .custom).then {
                $0.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
                $0.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
                $0.isSelected = initialCheckedItems[text] ?? false
                $0.addTarget(self, action: #selector(toggleCheckbox(_:)), for: .touchUpInside)
            }

            checkBoxes.append(checkbox)

            row.addArrangedSubview(label)
            row.addArrangedSubview(checkbox)

            let rowWrapper = UIView()
            rowWrapper.addSubview(row)
            row.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.top.bottom.equalToSuperview()
                $0.height.equalTo(44)
            }

            itemStack.addArrangedSubview(rowWrapper)

            if index < items.count - 1 {
                let separator = UIView().then {
                    $0.backgroundColor = .systemGray5
                }
                itemStack.addArrangedSubview(separator)
                separator.snp.makeConstraints { $0.height.equalTo(1) }
            }
        }

        boxView.addSubview(itemStack)
        itemStack.snp.makeConstraints { $0.edges.equalToSuperview() }

        let topStack = UIStackView(arrangedSubviews: [titleLabel, boxView]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        let guideLabel = UILabel().then {
            $0.text = "* 오후 10시 이후 야간수당을 받는 경우 체크해주세요"
            $0.font = .bodyMedium(12)
            $0.textColor = .gray500
            $0.numberOfLines = 0
        }

        addSubview(topStack)
        addSubview(guideLabel)

        topStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        guideLabel.snp.makeConstraints {
            $0.top.equalTo(topStack.snp.bottom).offset(4)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc private func toggleCheckbox(_ sender: UIButton) {
        guard let index = checkBoxes.firstIndex(of: sender) else { return }

        sender.isSelected.toggle()

        let tappedItem = items[index]

        if tappedItem == mainGroupItem {
            for (i, item) in items.enumerated() {
                if subGroupItems.contains(item) {
                    checkBoxes[i].isSelected = sender.isSelected
                }
            }
        } else if subGroupItems.contains(tappedItem) {
            let allChecked = subGroupItems.allSatisfy { item in
                guard let i = items.firstIndex(of: item) else { return false }
                return checkBoxes[i].isSelected
            }

            if let mainIndex = items.firstIndex(of: mainGroupItem) {
                checkBoxes[mainIndex].isSelected = allChecked
            }
        }
    }

    // MARK: - Public API

    func getSelectedConditions() -> [String] {
        return zip(items, checkBoxes)
            .filter { $0.1.isSelected }
            .map { $0.0 }
    }

    func setCheckboxEnabled(for item: String, isEnabled: Bool) {
        guard let index = items.firstIndex(of: item), checkBoxes.indices.contains(index) else { return }
        let checkbox = checkBoxes[index]
        checkbox.isEnabled = isEnabled
        checkbox.alpha = isEnabled ? 1.0 : 0.5
    }
}
