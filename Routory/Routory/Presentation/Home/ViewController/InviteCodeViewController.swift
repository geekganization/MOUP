//
//  InviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

/// 초대코드 화면의 상태를 나타내는 열거형입니다.
enum InviteCodeViewState {
    /// 사용자가 초대코드를 입력하는 초기 상태입니다.
    case input
    
    /// 초대코드로 근무지 조회가 완료된 후, 결과를 확인하고 정보를 입력하는 상태입니다.
    case result
}

final class InviteCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentState: InviteCodeViewState = .input
    
    /// 초대코드 플로우에서 사용자가 입력한 근무지 정보를 저장합니다.
    /// 이후 최종 등록 시 서버에 전달됩니다.
    private var selectedWorkplace: WorkplaceInfo?

    /// 초대코드 플로우에서 사용자가 입력한 알바생 상세 정보를 저장합니다.
    /// 이후 최종 등록 시 서버에 전달됩니다.
    private var selectedWorkerDetail: WorkerDetail?
    
    /// 초대코드 기반 근무지 조회 로직을 담당하는 ViewModel
    private let viewModel = InviteCodeViewModel(
        workplaceUseCase: WorkplaceUseCase(repository: WorkplaceRepository(service: WorkplaceService())),
        userUseCase: UserUseCase(userRepository: UserRepository(userService: UserService())),
        calendarUseCase: CalendarUseCase(repository: CalendarRepository(calendarService: CalendarService()))
    )

    /// 텍스트 필드에 입력된 초대코드를 실시간으로 반영하는 스트림
    private let inviteCodeSubject = BehaviorRelay<String>(value: "")

    /// "조회하기" 버튼이 눌렸을 때 발생하는 트리거 스트림
    private let searchTrigger = PublishSubject<Void>()
    
    private let registerTrigger = PublishSubject<(WorkplaceInfo, WorkerDetail)>()
    private let userIDRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let inviteCodeView = InviteCodeView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = inviteCodeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    private func updateState(to newState: InviteCodeViewState) {
        currentState = newState
        inviteCodeView.update(state: newState)
    }
}

private extension InviteCodeViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setActions()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
    }
    
    // MARK: - setActions
    func setActions() {
        inviteCodeView.workplaceSearchResultView.workplaceSelectView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(workplaceSelectViewDidTap)
            )
        )
    }
    
    func updateSearchButtonStyle(enabled: Bool) {
        let button = inviteCodeView.searchButtonView
        
        var config = button.configuration
        config?.baseBackgroundColor = enabled ? .primary500 : .gray300
        config?.baseForegroundColor = enabled ? .white : .gray500
        
        button.configuration = config
    }
    
    /// 근무지 선택 뷰가 탭되었을 때 호출됩니다.
    /// preset된 이름/카테고리를 전달하여 `WorkerWorkplaceRegistrationViewController`를 `.inputOnly` 모드로 push합니다.
    /// 사용자가 추가 정보를 입력하고 돌아오면 클로저를 통해 `Workplace`와 `WorkerDetail`을 전달받아 상태를 `.result`로 업데이트합니다.
    @objc func workplaceSelectViewDidTap() {
        let workerWorkplaceRegistrationVC = WorkerWorkplaceRegistrationViewController(
            workplaceId: selectedWorkplace?.id ?? "",
            isRegisterMode: false,
            isEdit: true,
            isHideWorkplaceInfoViewArrow: true,
            mode: .inputOnly,
            
            nameValue: selectedWorkplace?.workplace.workplacesName,
            categoryValue: selectedWorkplace?.workplace.category,

            salaryTypeValue: "매주",
            salaryCalcValue: "시급",
            fixedSalaryValue: "0",
            hourlyWageValue: "9,500",
            payDateValue: "금요일",
            payWeekdayValue: "금요일",
            
            isFourMajorSelected: false,
            isNationalPensionSelected: false,
            isHealthInsuranceSelected: false,
            isEmploymentInsuranceSelected: false,
            isIndustrialAccidentInsuranceSelected: false,
            isIncomeTaxSelected: false,
            isWeeklyAllowanceSelected: false,
            isNightAllowanceSelected: false,
            
            labelTitle: "초록색",
            showDot: true,
            dotColor: .systemGreen
        )
        
        workerWorkplaceRegistrationVC.onWorkplaceInfoPrepared = { [weak self] workerDetail in
            print("근무지 정보 등록완료 직후: \(workerDetail)")
            self?.selectedWorkerDetail = workerDetail
            self?.updateState(to: .result)
        }
        
        navigationController?.pushViewController(workerWorkplaceRegistrationVC, animated: true)
    }
    
    // MARK: - setBindings
    
    func setBindings() {
        // 네비게이션 바의 뒤로가기 버튼이 탭되었을 때 현재 화면을 pop하여 이전 화면으로 돌아갑니다.
        inviteCodeView.navigationBarView.backButtonView.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 텍스트 필드에 입력된 초대코드를 실시간으로 inviteCodeSubject에 바인딩하여 ViewModel에 전달합니다.
        inviteCodeView.codeTextFieldView.rx.text.orEmpty
            .bind(to: inviteCodeSubject)
            .disposed(by: disposeBag)
        
        // 텍스트 필드의 입력 여부에 따라 "조회하기" 버튼의 스타일(활성/비활성)을 업데이트합니다.
        inviteCodeView.codeTextFieldView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .subscribe(onNext: { [weak self] isEnabled in
                self?.updateSearchButtonStyle(enabled: isEnabled)
                self?.inviteCodeView.searchButtonView.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
        
        inviteCodeView.searchButtonView.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                switch self.currentState {
                case .input:
                    searchTrigger.onNext(())
                case .result:
                    print("result:")
                    guard let workplaceInfo = selectedWorkplace,
                          let workerDetail = selectedWorkerDetail else {
                        print("workerDetail 없음")
                        return
                    }
                    print("workplaceInfo: \(workplaceInfo), \(workerDetail)")
                    guard let user = Auth.auth().currentUser else {
                        print("로그인이 필요합니다.")
                        return
                    }

                    userIDRelay.accept(user.uid)
                    registerTrigger.onNext((workplaceInfo, workerDetail))
                }
            })
            .disposed(by: disposeBag)
        
        let input = InviteCodeViewModel.Input(
            inviteCode: inviteCodeSubject.asObservable(),
            searchTrigger: searchTrigger.asObservable(),
            registerTrigger: registerTrigger.asObservable(),
            userId: userIDRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.workplace
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                // 조회 성공 시 근무지 결과 뷰 업데이트
                self?.inviteCodeView.workplaceSearchResultView.update(
                    name: info.workplace.workplacesName,
                    category: info.workplace.category
                )
                // 근무지 정보 저장
                self?.selectedWorkplace = info
                // 상태를 `.result`로 전환
                self?.updateState(to: .result)
            })
            .disposed(by: disposeBag)

        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("에러 발생: \(error)")
                let modal = InviteCodeEmptyModalViewController()
                modal.modalPresentationStyle = .overFullScreen
                modal.modalTransitionStyle = .crossDissolve
                self?.present(modal, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.registrationSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    print("등록 완료")
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    print("등록 실패")
                }
            })
            .disposed(by: disposeBag)
    }
}
