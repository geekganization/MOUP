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
        print("didTapTypeRow")
    }

    func didTapCalcRow() {
        print("didTapCalcRow")
    }

    func didTapFixedSalaryRow() {
        print("didTapFixedSalaryRow")
        
    }

    func didTapPayDateRow() {
        print("didTapPayDateRow")
    }
}

extension WorkplaceRegistrationDelegateHandler: WorkplaceInfoViewDelegate {
    func didTapNameRow() {
        print("didTapNameRow")
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
            selected: "카페"
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
