//
//  OwnerWorkplaceRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/14/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import FirebaseAuth

final class OwnerWorkplaceRegistrationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let scrollView = UIScrollView()
    private let contentView = WorkplaceRegistrationContentView(workplaceTitle: "매장 *")
    
    private var delegateHandler: WorkplaceRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: "새 매장 등록")
    private let viewModel = CreateWorkplaceViewModel(
        useCase: WorkplaceUseCase(
            repository: WorkplaceRepository(
                service: WorkplaceService()
            )
        )
    )
    private let disposeBag = DisposeBag()
    
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
            inviteCode: UUID().uuidString,
            isOfficial: true
        )
        
        let workerDetail = WorkerDetail(
            workerName: "사장님",
            wage: 0,
            wageCalcMethod: "monthly",
            wageType: "",
            weeklyAllowance: false,
            payDay: 0,
            payWeekday: "",
            breakTimeMinutes: 0,
            employmentInsurance: false,
            healthInsurance: false,
            industrialAccident: false,
            nationalPension: false,
            incomeTax: false,
            nightAllowance: false,
            color: label
        )
        
        let input = CreateWorkplaceViewModel.Input(
            createTrigger: Observable.just(()),
            workplace: Observable.just(workplace),
            workerDetail: Observable.just(workerDetail),
            uid: Observable.just(uid),
            color: Observable.just(label),
            role: Observable.just(Role.owner)
        )
        
        let output = viewModel.transform(input: input)
        
        output.workplaceId
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] id in
                print("매장 등록 완료: \(id)")
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
