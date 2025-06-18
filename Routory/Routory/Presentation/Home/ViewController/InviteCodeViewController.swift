//
//  InviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa

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
    private var selectedWorkplace: Workplace?

    /// 초대코드 플로우에서 사용자가 입력한 알바생 상세 정보를 저장합니다.
    /// 이후 최종 등록 시 서버에 전달됩니다.
    private var selectedWorkerDetail: WorkerDetail?
    
    /// 초대코드 기반 근무지 조회 로직을 담당하는 ViewModel
    private let viewModel = InviteCodeViewModel(useCase: WorkplaceUseCase(repository: WorkplaceRepository(service: WorkplaceService())))

    /// 텍스트 필드에 입력된 초대코드를 실시간으로 반영하는 스트림
    private let inviteCodeSubject = BehaviorRelay<String>(value: "")

    /// "조회하기" 버튼이 눌렸을 때 발생하는 트리거 스트림
    private let searchTrigger = PublishSubject<Void>()
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
        let workerWorkplaceRegistraitionVC = WorkerWorkplaceRegistrationViewController(
            mode: .inputOnly,
            presetWorkplaceName: selectedWorkplace?.workplacesName,
            presetCategory: selectedWorkplace?.category
        )
        
        workerWorkplaceRegistraitionVC.onWorkplaceInfoPrepared = { [weak self] workerDetail in
            self?.selectedWorkerDetail = workerDetail
            self?.updateState(to: .result)
        }
        
        navigationController?.pushViewController(workerWorkplaceRegistraitionVC, animated: true)
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
            })
            .disposed(by: disposeBag)
        
        inviteCodeView.searchButtonView.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                switch self.currentState {
                case .input:
                    // 사용자가 "조회하기" 버튼을 눌렀을 때 ViewModel로 검색 트리거 이벤트를 전달
                    searchTrigger.onNext(())
                case .result:
                    // 하위 VC에서 입력한 근무지 및 알바생 정보를 확인
                    guard let workplace = selectedWorkplace,
                          let workerDetail = selectedWorkerDetail else {
                        return
                    }

                    // TODO: ViewModel 또는 UseCase를 통해 서버에 등록 요청을 보냅니다
                    // 현재는 임시로 로그만 출력하고 화면을 종료함
                    print("등록하기: \(workplace), \(workerDetail)")
                    navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        let input = InviteCodeViewModel.Input(
            inviteCode: inviteCodeSubject.asObservable(),
            searchTrigger: searchTrigger.asObservable()
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
                self?.selectedWorkplace = info.workplace
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
    }
}
