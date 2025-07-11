//
//  WorkplaceRegistrationDelegateHandler.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import RxSwift

final class WorkplaceRegistrationDelegateHandler: NSObject {
    weak var contentView: WorkplaceRegistrationContentView?
    weak var navigationController: UINavigationController?
    private let disposeBag = DisposeBag()
    
    init(contentView: WorkplaceRegistrationContentView, navigationController: UINavigationController?) {
        self.contentView = contentView
        self.navigationController = navigationController
    }
}

extension WorkplaceRegistrationDelegateHandler: WorkplaceInfoViewDelegate {
    
    func didTapWorkerManagerRow(workplaceId: String) {
        let useCase = WorkplaceUseCase(repository: WorkplaceRepository(service: WorkplaceService()))
        
        useCase.fetchWorkerListForWorkplace(workplaceId: workplaceId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] workerList in
                let vc = WorkerListViewController(workerList: workerList, workerPlaceId: workplaceId)
                self?.navigationController?.pushViewController(vc, animated: true)
            }, onError: { error in
                print("알바생 목록 불러오기 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func didTapNameRow() {
        let vc = TextInputViewController(
            title: "근무지 이름",
            description: "근무지 이름을 입력해주세요",
            placeholder: "근무지 이름"
        )
        vc.onComplete = { labelName in
            self.contentView?.workplaceInfoView.updateName(labelName)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapCategoryRow() {
        let categoryItems: [SelectionViewController<String>.Item] = [
            .init(title: "음식점", icon: "Restaurant", value: "음식점"),
            .init(title: "카페", icon: "Cafe", value: "카페"),
            .init(title: "편의점", icon: "CVS", value: "편의점"),
            .init(title: "영화관", icon: "Theater", value: "영화관"),
            .init(title: "기타", icon: "Etc", value: "기타")
        ]

        let vc = SelectionViewController<String>(
            title: "카테고리",
            description: "근무지 카테고리를 선택해주세요",
            items: categoryItems,
            selected: "음식점"
        )

        vc.onSelect = { [weak self] selected in
            self?.contentView?.workplaceInfoView.updateCategory(selected)
        }
        navigationController?.pushViewController(vc, animated: true)
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

        vc.onSelect = { [weak self] selected in
            self?.contentView?.salaryInfoView.updateTypeValue(selected)
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

        vc.onSelect = { [weak self] selected in
            print("선택된 계산 방법:", selected)
            self?.contentView?.salaryInfoView.updateCalcValue(selected)
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
            self.contentView?.salaryInfoView.updateFixedSalaryValue(value)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapHourlyWageRow() {
        let vc = TextInputViewController(
            title: "시급",
            description: "시급을 입력해주세요",
            placeholder: "10,030원",
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
            self.contentView?.salaryInfoView.updateHourlyWageValue(value)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapPayDateRow() {
        let days = (1...31).map { "\($0)일" }

        let vc = ReusablePickerViewController(data: [days]) { selectedIndexes in
            let index = selectedIndexes[0]
            print("선택한 날: \(days[index])")
            self.contentView?.salaryInfoView.updatePayDateValue(days[index])
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 16
        }

        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func didTapPayWeekdayRow() {
        let weekDays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]

        let vc = ReusablePickerViewController(data: [weekDays]) { selectedIndexes in
            let index = selectedIndexes[0]
            self.contentView?.salaryInfoView.updatePayWeekdayValue(weekDays[index])
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 16
        }

        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        navigationController?.present(vc, animated: true, completion: nil)
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
