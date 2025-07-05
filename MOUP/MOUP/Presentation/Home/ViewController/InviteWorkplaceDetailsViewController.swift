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
            .subscribe(onNext: {
                print("paymentCycleRow did tap")
            })
            .disposed(by: disposeBag)
        
        inviteWorkplaceDetails.paymentMethodRowDidTap
            .subscribe(onNext: {
                print("paymentMethodRow did tap")
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
