//
//  WorkerWorkplaceRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import FirebaseAuth

final class WorkerWorkplaceRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = WorkplaceRegistrationContentView(workplaceTitle: "근무지 *")

    private var delegateHandler: WorkplaceRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: "새 근무지 등록") //*2
    
    private let viewModel = CreateWorkplaceViewModel(
        useCase: CreateWorkerWorkplaceUseCase(
            repository: WorkerWorkplaceRepository(
                userService: UserService() // 또는 적절한 구현체
            )
        )
    )
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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

        delegateHandler = WorkplaceRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.salaryInfoView.delegate = delegateHandler
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
        let salaryType = contentView.salaryInfoView.getTypeValue()
        let salaryCalc = contentView.salaryInfoView.getCalcValue()
        let fixedSalary = contentView.salaryInfoView.getFixedSalaryValue()
        let hourlyWage = contentView.salaryInfoView.getHourlyWageValue()
        let payWeekday = contentView.salaryInfoView.getPayWeekdayValue()
        let payDate = contentView.salaryInfoView.getPayDateValue()
        let selectedConditions = contentView.workConditionView.getSelectedConditions()
        let label = contentView.labelView.getColorLabelData()

        let (wage, wageCalcMethod): (Int, String) = {
            switch salaryType {
            case "매월":
                return (parseCurrencyStringToInt(fixedSalary), "monthly")
            case "매주", "매일":
                return (parseCurrencyStringToInt(hourlyWage), "hourly")
            default:
                return (0, "hourly")
            }
        }()

        let employmentInsurance = selectedConditions.contains("고용보험")
        let healthInsurance = selectedConditions.contains("건강보험")
        let industrialAccident = selectedConditions.contains("산재보험")
        let nationalPension = selectedConditions.contains("국민연금")
        let incomeTax = selectedConditions.contains("소득세")
        let weeklyAllowance = selectedConditions.contains("주휴수당")
        let nightAllowance = selectedConditions.contains("야간수당*")

        let breakTimeMinutes = 0

        let workplace = Workplace(
            workplacesName: name,
            category: category,
            ownerId: Auth.auth().currentUser?.uid ?? "",
            inviteCode: UUID().uuidString,
            isOfficial: false
        )

        let workerDetail = WorkerDetail(
            workerName: "알바생 이름",
            wage: wage,
            wageCalcMethod: wageCalcMethod,
            wageType: salaryType,
            weeklyAllowance: weeklyAllowance,
            payDay: parseDateStringToInt(payDate),
            payWeekday: payWeekday,
            breakTimeMinutes: breakTimeMinutes,
            employmentInsurance: employmentInsurance,
            healthInsurance: healthInsurance,
            industrialAccident: industrialAccident,
            nationalPension: nationalPension,
            incomeTax: incomeTax,
            nightAllowance: nightAllowance,
            color: label
        )

        let input = CreateWorkplaceViewModel.Input(
            createTrigger: Observable.just(()),
            workplace: Observable.just(workplace),
            workerDetail: Observable.just(workerDetail),
            uid: Observable.just(Auth.auth().currentUser?.uid ?? "") 
        )

        let output = viewModel.transform(input: input)

        output.workplaceId
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] id in
                print("등록 완료: \(id)")
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("에러 발생: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
