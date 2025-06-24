//
//  OwnerWorkplaceEditViewController.swift
//  Routory
//
//  Created by tlswo on 6/24/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import FirebaseAuth

final class OwnerWorkplaceEditViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let scrollView = UIScrollView()
    private let contentView: WorkplaceRegistrationContentView
    
    private var delegateHandler: WorkplaceRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    
    fileprivate var navigationBar: BaseNavigationBar
//    private let viewModel = CreateWorkplaceViewModel(
//        useCase: WorkplaceUseCase(
//            repository: WorkplaceRepository(
//                service: WorkplaceService()
//            )
//        )
//    )
    private let disposeBag = DisposeBag()
        
    private let workPlaceID: String
        
    // MARK: - Lifecycle
    
    init(
        workPlaceID: String,
        nameValue: String?,
        categoryValue: String?,
        labelTitle: String,
        showDot: Bool,
        dotColor: UIColor?
    ) {
        self.workPlaceID = workPlaceID
        self.contentView = WorkplaceRegistrationContentView(
            workplaceId: workPlaceID,
            isEdit: false,
            nameValue: nameValue,
            categoryValue: categoryValue,
            salaryTypeValue: "매월",
            salaryCalcValue: "고정",
            fixedSalaryValue: "2,000,000",
            hourlyWageValue: "12,000",
            payDateValue: "15일",
            payWeekdayValue: "금요일",
            isFourMajorSelected: true,
            isNationalPensionSelected: false,
            isHealthInsuranceSelected: true,
            isEmploymentInsuranceSelected: true,
            isIndustrialAccidentInsuranceSelected: false,
            isIncomeTaxSelected: true,
            isWeeklyAllowanceSelected: false,
            isNightAllowanceSelected: true,
            labelTitle: labelTitle,
            showDot: showDot,
            dotColor: dotColor,
            registerBtnTitle: "적용하기"
        )
        navigationBar = BaseNavigationBar(title: nameValue ?? "매장 수정")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.salaryInfoView.isHidden = true
        contentView.workConditionView.isHidden = true
        
        delegateHandler = WorkplaceRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)
        
        contentView.workplaceInfoView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler
        
        contentView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchDown(_:)), for: .touchDown)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func layout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapRegister() {
        let name = contentView.workplaceInfoView.getName()
        let category = contentView.workplaceInfoView.getCategory()
        let label = contentView.labelView.getColorLabelData()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("유저 UID가 존재하지 않음")
            return
        }

        let workplace = Workplace(
            workplacesName: name,
            category: category,
            ownerId: uid,
            inviteCode: InviteCodeGenerator.generate(userID: uid), // 초대 코드 생성
            isOfficial: true
        )
        
        // 업데이트 로직
        print(workplace,label)
        
        //navigationController?.popViewController(animated: true)
    }
}
