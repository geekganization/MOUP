//
//  WorkplaceRegistrationDelegateHandler.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit

final class WorkplaceRegistrationDelegateHandler: NSObject {
    weak var contentView: WorkplaceRegistrationContentView?
    weak var navigationController: UINavigationController?

    init(contentView: WorkplaceRegistrationContentView, navigationController: UINavigationController?) {
        self.contentView = contentView
        self.navigationController = navigationController
    }
}

extension WorkplaceRegistrationDelegateHandler: SalaryInfoViewDelegate {
    func didTapTypeRow() {
        let items = [
            SelectionViewController<String>.Item(title: "매월", icon: nil, value: "매월"),
            SelectionViewController<String>.Item(title: "매주", icon: nil, value: "매주"),
            SelectionViewController<String>.Item(title: "매일", icon: nil, value: "매일")
        ]

        let vc = SelectionViewController<String>(
            title: "급여 유형",
            description: "급여 유형을 선택해주세요",
            items: items,
            selected: "매월"
        )

        vc.onSelect = { selected in
            print("선택된 급여 유형:", selected)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapCalcRow() {
        let items = [
            SelectionViewController<String>.Item(title: "시급", icon: nil, value: "시급"),
            SelectionViewController<String>.Item(title: "고정", icon: nil, value: "고정")
        ]

        let vc = SelectionViewController<String>(
            title: "급여 계산",
            description: "급여 계산방법을 선택해주세요",
            items: items,
            selected: "고정"
        )

        vc.onSelect = { selected in
            print("선택된 계산 방법:", selected)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapFixedSalaryRow() {
        let vc = TextInputViewController(
            title: "고정급",
            description: "고정급을 입력해주세요",
            placeholder: "3,000,000원",
            keyboardType: .numberPad,
            formatter: { input in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                let num = Int(input) ?? 0
                return formatter.string(from: NSNumber(value: num)) ?? ""
            },
            validator: { input in
                Int(input.replacingOccurrences(of: ",", with: "")) != nil
            }
        )
        vc.onComplete = { value in
            print("입력된 값: \(value)")
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapPayDateRow() {
        print("didTapPayDateRow")
    }
}

extension WorkplaceRegistrationDelegateHandler: WorkplaceInfoViewDelegate {
    func didTapNameRow() {
        let vc = TextInputViewController(
            title: "근무지 이름",
            description: "근무지 이름을 입력해주세요",
            placeholder: "예: 세븐일레븐 안양점"
        )
        vc.onComplete = { labelName in
            print("입력된 근무지: \(labelName)")
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapCategoryRow() {
        let categoryItems: [SelectionViewController<String>.Item] = [
            .init(title: "음식점", icon: UIImage(named: "restaurant"), value: "음식점"),
            .init(title: "카페", icon: UIImage(named: "cafe"), value: "카페"),
            .init(title: "편의점", icon: UIImage(named: "convenience"), value: "편의점"),
            .init(title: "영화관", icon: UIImage(named: "cinema"), value: "영화관"),
            .init(title: "기타", icon: UIImage(named: "box"), value: "기타")
        ]

        let vc = SelectionViewController<String>(
            title: "카테고리",
            description: "근무지 카테고리를 선택해주세요",
            items: categoryItems,
            selected: "음식점"
        )

        vc.onSelect = { selected in
            print("선택된 카테고리:", selected)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WorkplaceRegistrationDelegateHandler: LabelViewDelegate {
    func labelViewDidTapSelectColor(_ sender: LabelView) {
        let vc = ColorSelectionViewController()
        vc.onSelect = { [weak self] labelColor in
            self?.contentView?.labelView.updateLabelName(labelColor.name, color: labelColor.color)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
