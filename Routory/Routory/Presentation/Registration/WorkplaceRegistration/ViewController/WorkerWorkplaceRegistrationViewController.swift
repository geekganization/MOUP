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

/// 근무지 등록 화면의 동작 모드를 정의합니다.
enum WorkplaceRegistrationMode {
    /// 직접 등록 플로우 - 사용자가 모든 정보를 수동으로 입력하고 즉시 등록까지 수행
    case fullRegistration
    
    /// 초대 코드 기반 플로우 - 상위 VC에서 전달된 일부 정보(name, category)를 바탕으로 나머지 정보만 작성
    /// 최종 등록은 상위 VC에서 수행
    case inputOnly
}

final class WorkerWorkplaceRegistrationViewController: UIViewController,UIGestureRecognizerDelegate {
    
    private let scrollView = UIScrollView()
    
    private let contentView: WorkplaceRegistrationContentView
    
    private var delegateHandler: WorkplaceRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: "새 근무지 등록") //*2
    
    private let viewModel = CreateWorkplaceViewModel(
        useCase: WorkplaceUseCase(
            repository: WorkplaceRepository(
                service: WorkplaceService()
            )
        )
    )
    private let disposeBag = DisposeBag()
    
    /// 근무지 등록 방식 (직접 입력 or 초대코드 기반)
    private let mode: WorkplaceRegistrationMode
    
    /// `.inputOnly` 모드에서 사용자 입력이 완료되었을 때 호출되는 콜백입니다.
    /// 상위 VC로 `WorkerDetail` 정보를 전달합니다.
    var onWorkplaceInfoPrepared: ((WorkerDetail) -> Void)?
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Initializer
    
    /// 근무지 등록 화면을 생성합니다.
    /// - Parameters:
    ///   - mode: 등록 방식 (`.fullRegistration` 또는 `.inputOnly`)
    ///   - presetWorkplaceName: `.inputOnly` 모드에서 사용할 근무지 이름 (기본값: nil)
    ///   - presetCategory: `.inputOnly` 모드에서 사용할 카테고리 (기본값: nil)
    init(
        isRead: Bool = false,
        mode: WorkplaceRegistrationMode,
        nameValue: String?,
        categoryValue: String?,
        salaryTypeValue: String,
        salaryCalcValue: String,
        fixedSalaryValue: String,
        hourlyWageValue: String,
        payDateValue: String,
        payWeekdayValue: String,
        isFourMajorSelected: Bool,
        isNationalPensionSelected: Bool,
        isHealthInsuranceSelected: Bool,
        isEmploymentInsuranceSelected: Bool,
        isIndustrialAccidentInsuranceSelected: Bool,
        isIncomeTaxSelected: Bool,
        isWeeklyAllowanceSelected: Bool,
        isNightAllowanceSelected: Bool,
        labelTitle: String,
        showDot: Bool,
        dotColor: UIColor?
    ) {
        self.mode = mode

        self.contentView = WorkplaceRegistrationContentView(
            isRead: isRead,
            nameValue: nameValue,
            categoryValue: categoryValue,
            salaryTypeValue: salaryTypeValue,
            salaryCalcValue: salaryCalcValue,
            fixedSalaryValue: fixedSalaryValue,
            hourlyWageValue: hourlyWageValue,
            payDateValue: payDateValue,
            payWeekdayValue: payWeekdayValue,
            isFourMajorSelected: isFourMajorSelected,
            isNationalPensionSelected: isNationalPensionSelected,
            isHealthInsuranceSelected: isHealthInsuranceSelected,
            isEmploymentInsuranceSelected: isEmploymentInsuranceSelected,
            isIndustrialAccidentInsuranceSelected: isIndustrialAccidentInsuranceSelected,
            isIncomeTaxSelected: isIncomeTaxSelected,
            isWeeklyAllowanceSelected: isWeeklyAllowanceSelected,
            isNightAllowanceSelected: isNightAllowanceSelected,
            labelTitle: labelTitle,
            showDot: showDot,
            dotColor: dotColor
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        // 숨김 처리 - 기능 완성되면 나중에 지워야 함
        contentView.workConditionView.isHidden = true
        contentView.labelView.isHidden = true
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
        
        let wage: Int = {
            switch salaryCalc {
            case "시급":
                return (parseCurrencyStringToInt(hourlyWage))
            case "고정":
                return (parseCurrencyStringToInt(fixedSalary))
            default:
                return (0)
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
            inviteCode: "",
            isOfficial: false
        )
        
        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("유저 UID가 존재하지 않음")
            return
        }
        
        // 비동기 처리 위치: 여기서 workerDetail을 만들어야 함
        UserManager.shared.getUser { [weak self] result in
            switch result {
            case .success(let user):
                let workerDetail = WorkerDetail(
                    workerName: user.userName,
                    wage: wage,
                    wageCalcMethod: salaryType,
                    wageType: salaryCalc,
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
                
                guard let self = self else { return }
                
                switch self.mode {
                case .fullRegistration:
                    let input = CreateWorkplaceViewModel.Input(
                        createTrigger: Observable.just(()),
                        workplace: Observable.just(workplace),
                        workerDetail: Observable.just(workerDetail),
                        uid: Observable.just(uid),
                        color: Observable.just(label),
                        role: Observable.just(Role.worker)
                    )
                    
                    let output = self.viewModel.transform(input: input)
                    
                    output.workplaceId
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] id in
                            print("등록 완료: \(id)")
                            self?.navigationController?.popViewController(animated: true)
                        })
                        .disposed(by: self.disposeBag)
                    
                    output.error
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { error in
                            print("에러 발생: \(error.localizedDescription)")
                        })
                        .disposed(by: self.disposeBag)
                    
                case .inputOnly:
                    self.onWorkplaceInfoPrepared?(workerDetail)
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let error):
                print("사용자 이름 가져오기 실패: \(error.localizedDescription)")
            }
        }
    }
}
