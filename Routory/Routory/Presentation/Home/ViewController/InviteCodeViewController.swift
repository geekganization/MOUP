//
//  InviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit

enum InviteCodeViewState {
    case input
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
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
    }
    
    // MARK: - setActions
    func setActions() {
        inviteCodeView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButtonDidTap),
            for: .touchUpInside
        )
        
        inviteCodeView.codeTextFieldView.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        inviteCodeView.workplaceSearchResultView.workplaceSelectView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(workplaceSelectViewDidTap)
            )
        )
        
        inviteCodeView.searchButtonView.addTarget(
            self,
            action: #selector(searchButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true
        updateSearchButtonStyle(enabled: !isEmpty)
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
            presetWorkplaceName: "GS편의점 서울역점",
            presetCategory: "편의점"
        )
        
        workerWorkplaceRegistraitionVC.onWorkplaceInfoPrepared = { [weak self] workplace, workerDetail in
            self?.selectedWorkplace = workplace
            self?.selectedWorkerDetail = workerDetail
            self?.updateState(to: .result)
        }
        
        navigationController?.pushViewController(workerWorkplaceRegistraitionVC, animated: true)
    }
    
    @objc func searchButtonDidTap() {
        switch currentState {
        case .input:
            // TODO: 서버에 초대코드로 근무지 조회
            print("조회하기")
            updateState(to: .result)
            
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
    }
}
