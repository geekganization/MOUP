//
//  ShiftRegistrationActionHandler.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit

final class ShiftRegistrationActionHandler: NSObject {

    weak var contentView: ShiftRegistrationContentView?
    weak var navigationController: UINavigationController?

    init(contentView: ShiftRegistrationContentView, navigationController: UINavigationController?) {
        self.contentView = contentView
        self.navigationController = navigationController
    }

    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc func didTapRegister() {
        guard let view = contentView else { return }
        print(view.simpleRowView.getData())
        print(view.workerSelectionView.getSelectedWorkerData())
        print(view.routineView.getTitleData())
        print(view.workDateView.getdateRowData())
        print(view.workDateView.getrepeatRowData())
        print(view.labelView.getColorData())
        print(view.labelView.getColorLabelData())
        print(view.workTimeView.getstartRowData())
        print(view.workTimeView.getrestRowData())
        print(view.workTimeView.getendRowData())
        print(view.memoBoxView.getData())
    }

    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.6
        }
    }

    @objc func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }
}
