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
    private let contentView = WorkplaceRegistrationContentView(workplaceTitle: "근무지 *")
    
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

    /// 초대코드 플로우에서 전달받은 근무지 이름 (직접 입력 모드에서는 nil)
    private let presetWorkplaceName: String?

    /// 초대코드 플로우에서 전달받은 카테고리 (직접 입력 모드에서는 nil)
    private let presetCategory: String?
    
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
        mode: WorkplaceRegistrationMode,
        presetWorkplaceName: String? = nil,
        presetCategory: String? = nil
    ) {
        self.mode = mode
        self.presetWorkplaceName = presetWorkplaceName
        self.presetCategory = presetCategory
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
        
        // 초대코드 기반 플로우인 경우, 상위 VC에서 전달받은 근무지 이름과 카테고리를
        // ContentView에 설정하고 편집 불가능하도록 처리
        if mode == .inputOnly {
            contentView.setPresetWorkplaceInfo(name: presetWorkplaceName ?? "", category: presetCategory ?? "")
        }
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
        
        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("유저 UID가 존재하지 않음")
            return
        }
        
        switch mode {
        case .fullRegistration:
            let input = CreateWorkplaceViewModel.Input(
                createTrigger: Observable.just(()),
                workplace: Observable.just(workplace),
                workerDetail: Observable.just(workerDetail),
                uid: Observable.just(uid),
                color: Observable.just(label),
                role: Observable.just(Role.worker),
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
        case .inputOnly:
            // 초대코드 플로우:
            // 입력된 정보를 상위 VC로 전달하고 현재 화면을 닫습니다.
            onWorkplaceInfoPrepared?(workerDetail)
            navigationController?.popViewController(animated: true)
        }
    }
}
