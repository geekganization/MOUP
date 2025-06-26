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

    private let navigationBar: BaseNavigationBar
    private let disposeBag = DisposeBag()

    private let workPlaceID: String

    private let viewModel = OwnerWorkplaceEditViewModel(
        workplaceUseCase: WorkplaceUseCase(
            repository: WorkplaceRepository(service: WorkplaceService())
        )
    )
    private let updateTrigger = PublishSubject<(
        workplaceId: String,
        name: String,
        category: String,
        uid: String,
        color: String
    )>()

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
            isWorkerManagerShow: true,
            isHideWorkplaceInfoViewArrow: false,
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
        self.navigationBar = BaseNavigationBar(title: nameValue ?? "매장 수정")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

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

    private func bindViewModel() {
        let input = OwnerWorkplaceEditViewModel.Input(updateTrigger: updateTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isLoading in
                print("로딩 중: \(isLoading)")
            })
            .disposed(by: disposeBag)

        output.successMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (message: String) in
                print(message)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (message: String) in
                print("에러: \(message)")
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapRegister() {
        let name = contentView.workplaceInfoView.getName()
        let category = contentView.workplaceInfoView.getCategory()
        let label = contentView.labelView.getColorLabelData()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("유저 UID가 존재하지 않음")
            return
        }
        
        updateTrigger.onNext((
            workplaceId: workPlaceID,
            name: name,
            category: category,
            uid: uid,
            color: label
        ))
    }
}
