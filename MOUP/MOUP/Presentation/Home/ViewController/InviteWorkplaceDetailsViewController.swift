//
//  InviteWorkplaceDetailsViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class InviteWorkplaceDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let inviteWorkplaceDetails = InviteWorkplaceDetails()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = inviteWorkplaceDetails
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension InviteWorkplaceDetailsViewController {
    // MARK: - configure
    func configure() {
        setActions()
    }
    
    // MARK: - setActions
    func setActions() {
        inviteWorkplaceDetails.backButtonDidTap
            .subscribe(onNext: {
                print("backButton did tap")
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.paymentCycleRowDidTap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let vc = InputSelectionViewController(
                    navigationTitle: "급여 유형",
                    guideMessage: "급여 유형을 선택해주세요",
                    selectionItems: ["매월", "매주", "매일"]
                )
                
                vc.completeRelay
                    .subscribe(onNext: { selectedTitle in
                        print("선택한 급여 유형: \(selectedTitle)")
                    })
                    .disposed(by: self.disposeBag)
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.paymentMethodRowDidTap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let vc = InputSelectionViewController(
                    navigationTitle: "급여 계산",
                    guideMessage: "급여 계산 방법을 선택해주세요",
                    selectionItems: ["시급", "고정"]
                )
                
                vc.completeRelay
                    .subscribe(onNext: { selectedTitle in
                        print("선택한 급여 계산 방법: \(selectedTitle)")
                    })
                    .disposed(by: self.disposeBag)
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.wageCalculationTypeRowDidTap
            .subscribe(onNext: {
                print("wageCalculationTypeRow did tap")
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.paydayRowDidTap
            .subscribe(onNext: {
                print("paydayRow did tap")
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.colorPickerRowDidTap
            .subscribe(onNext: {
                print("colorPickerRow did tap")
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.completeButtonDidTap
            .subscribe(onNext: {
                print("submitButton did tap")
            })
            .disposed(by: disposeBag)
    }
}
