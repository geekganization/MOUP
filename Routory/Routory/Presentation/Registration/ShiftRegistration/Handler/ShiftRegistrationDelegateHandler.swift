//
//  ShiftRegistrationDelegateHandler.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import Then
import SnapKit

final class ShiftRegistrationDelegateHandler: NSObject {

    weak var contentView: ShiftRegistrationContentView?
    weak var navigationController: UINavigationController?

    init(contentView: ShiftRegistrationContentView, navigationController: UINavigationController?) {
        self.contentView = contentView
        self.navigationController = navigationController
    }
}

// MARK: - SimpleRowViewDelegate

extension ShiftRegistrationDelegateHandler: WorkPlaceSelectionViewDelegate {
    func workPlaceSelectionViewDidTapChevron(_ view: WorkPlaceSelectionView) {
        let workplaces: [Workplace] = [
//            Workplace(id: "1", workplacesName: "맥도날드", category: "패스트푸드", ownerId: "owner1", inviteCode: "...", inviteCodeExpiresAt: "...", isOfficial: true),
//            Workplace(id: "2", workplacesName: "쿠팡 야간", category: "물류", ownerId: "owner2", inviteCode: "...", inviteCodeExpiresAt: "...", isOfficial: false),
//            Workplace(id: "3", workplacesName: "올리브영", category: "뷰티", ownerId: "owner3", inviteCode: "...", inviteCodeExpiresAt: "...", isOfficial: true)
        ]

        let workplaceItems = workplaces.map {
            SelectionViewController<Workplace>.Item(
                title: $0.workplacesName,
                icon: nil,
                value: $0
            )
        }
        
        let vc = SelectionViewController<Workplace>(
            title: "근무지 선택",
            description: "등록할 근무지를 선택해 주세요",
            items: workplaceItems,
            selected: nil
        )
        
        vc.onSelect = { [weak self] workplace in
            self?.contentView?.simpleRowView.updateTitle(workplace.workplacesName)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - RoutineViewDelegate

extension ShiftRegistrationDelegateHandler: RoutineViewDelegate {
    func routineViewDidTapAdd() {
        let vc = RoutineSelectionViewController()
        vc.onSelect = { [weak self] routines in
            guard let self, let first = routines.first else { return }

            let displayText = first.routineName
            if routines.count > 1 {
                let displayCount = "+\(routines.count - 1)"
                self.contentView?.routineView.updateCounterLabel(displayCount)
            }
            self.contentView?.routineView.updateSelectedRoutine(displayText)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - LabelViewDelegate

extension ShiftRegistrationDelegateHandler: LabelViewDelegate {
    func labelViewDidTapSelectColor(_ sender: LabelView) {
        let vc = ColorSelectionViewController()
        vc.onSelect = { [weak self] labelColor in
            self?.contentView?.labelView.updateLabelName(labelColor.name, color: labelColor.color)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - WorkDateViewDelegate

extension ShiftRegistrationDelegateHandler: WorkDateViewDelegate {
    func didTapRepeatRow(from view: WorkDateView) {
        let vc = RepeatDaysViewController()
        vc.onSelectDays = { [weak view] shortLabel in
            view?.updateRepeatValue(shortLabel)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapDateRow(completion: @escaping (Date) -> Void) {
        let alert = UIAlertController(title: "날짜 선택", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)

        let datePicker = UIDatePicker().then {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .wheels
            $0.frame = CGRect(x: 0, y: 30, width: alert.view.bounds.width - 20, height: 160)
        }

        alert.view.addSubview(datePicker)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion(datePicker.date)
        }))

        navigationController?.present(alert, animated: true)
    }
}

// MARK: - WorkTimeViewDelegate

extension ShiftRegistrationDelegateHandler: WorkTimeViewDelegate {
    func workTimeViewDidRequestTimePicker(for type: WorkTimeView.TimeType, current: String) {
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let picker = UIDatePicker().then {
            $0.datePickerMode = .time
            $0.preferredDatePickerStyle = .wheels
            $0.locale = Locale(identifier: "ko_KR")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: current) {
            picker.date = date
        }

        alert.view.addSubview(picker)
        picker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            let newValue = formatter.string(from: picker.date)
            self?.contentView?.workTimeView.updateValue(for: type, newValue: newValue)
        }))

        navigationController?.present(alert, animated: true)
    }

    func workTimeViewDidRequestBreakTimePicker(current: String) {
        let timesInMinutes = Array(stride(from: 30, through: 180, by: 30))
        let displayTexts = ["없음"] + timesInMinutes.map { minutes -> String in
            let hour = minutes / 60
            let minute = minutes % 60
            return hour > 0 ? "\(hour)시간\(minute > 0 ? " \(minute)분" : "")" : "\(minute)분"
        }

        let vc = ReusablePickerViewController(data: [displayTexts]) { [weak self] selectedIndexes in
            let selectedIndex = selectedIndexes[0]
            let selectedText = displayTexts[selectedIndex]
            self?.contentView?.workTimeView.updateRestValue(selectedText)
        }

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 16
        }

        navigationController?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - WorkerSelectionViewDelegate

extension ShiftRegistrationDelegateHandler: WorkerSelectionViewDelegate {
    func workerSelectionViewDidTap() {
        let employeeVC = EmployeeSelectionViewController()
        employeeVC.onSelect = { [weak self] selectedEmployees in
            guard let self = self,
                  let firstName = selectedEmployees.first?.name else { return }

            self.contentView?.workerSelectionView.updateSelectedEmployees(selectedEmployees)
            if selectedEmployees.count == 1 {
                self.contentView?.workerSelectionView.updateSelectedTitle(firstName)
            } else {
                self.contentView?.workerSelectionView.updateSelectedTitle("\(firstName) 외 \(selectedEmployees.count - 1)명")
            }
        }

        navigationController?.pushViewController(employeeVC, animated: true)
    }
}

