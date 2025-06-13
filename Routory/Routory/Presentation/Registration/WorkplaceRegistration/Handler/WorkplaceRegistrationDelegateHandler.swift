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
        print("didTapCategoryRow")
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
