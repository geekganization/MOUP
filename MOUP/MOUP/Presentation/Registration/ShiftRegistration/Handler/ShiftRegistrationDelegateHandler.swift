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
    private let viewModel: WorkplaceListViewModel

    init(contentView: ShiftRegistrationContentView, navigationController: UINavigationController?, viewModel: WorkplaceListViewModel) {
        self.contentView = contentView
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
}

// MARK: - SimpleRowViewDelegate

extension ShiftRegistrationDelegateHandler: WorkPlaceSelectionViewDelegate {
    func workPlaceSelectionViewDidTapChevron(_ view: WorkPlaceSelectionView) {

        let workplaceItems = viewModel.workplaceInfos.map {
            SelectionViewController<WorkplaceInfo>.Item(
                title: $0.workplace.workplacesName,
                icon: nil,
                value: $0
            )
        }

        let vc = SelectionViewController<WorkplaceInfo>(
            title: "근무지 선택",
            description: "등록할 근무지를 선택해 주세요",
            items: workplaceItems,
            selected: nil
        )

        vc.onSelect = { [weak self] workplaceInfo in
            self?.contentView?.simpleRowView.updateID(workplaceInfo.id)
            self?.contentView?.simpleRowView.updateTitle(workplaceInfo.workplace.workplacesName)
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

            let displayText = first.routine.routineName
            if routines.count > 1 {
                let displayCount = "+\(routines.count - 1)"
                self.contentView?.routineView.updateCounterLabel(displayCount)
            } else {
                self.contentView?.routineView.updateCounterLabel("")
            }
            self.contentView?.routineView.updateSelectedRoutine(displayText)
            self.contentView?.routineView.updateSelectedRoutineData(routines)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - WorkDateViewDelegate

extension ShiftRegistrationDelegateHandler: WorkDateViewDelegate {
    func didTapRepeatRow(from view: WorkDateView) {
        let vc = RepeatDaysViewController()
        vc.onSelectDays = { [weak view] repeatDays in
            let display = repeatDays.joined(separator: ", ")
            view?.updateRepeatData(repeatDays)
            view?.updateRepeatValue(display)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let vc = TimePickerViewController()
        if let date = formatter.date(from: current) {
            vc.setInitialDate(date)
        }

        vc.onConfirm = { [weak self] newDate in
            let newValue = formatter.string(from: newDate)
            self?.contentView?.workTimeView.updateValue(for: type, newValue: newValue)
        }

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        navigationController?.present(vc, animated: true)
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

        navigationController?.present(vc, animated: true)
    }
}

// MARK: - WorkerSelectionViewDelegate

extension ShiftRegistrationDelegateHandler: WorkerSelectionViewDelegate {
    func workerSelectionViewDidTap() {
        let employeeVC = EmployeeSelectionViewController()
        
        guard let workPlaceID = contentView?.simpleRowView.getID(), !workPlaceID.isEmpty else {
            print("workPlaceID가 비어있습니다.")
            return
        }
        
        employeeVC.setWorkplaceId(workPlaceID)
        
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

