//
//  HomeViewController.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

import RxSwift
import RxRelay
import RxDataSources
import SnapKit
import Then

enum UserType {
    case worker
    case owner

    init(role: String) {
        switch role {
        case "worker": self = .worker
        case "owner": self = .owner
        default: self = .worker
        }
    }
}

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private let homeView = HomeView()
    private let homeViewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let refreshBtnTappedRelay = PublishRelay<Void>()
    private let cellTappedRelay = PublishRelay<IndexPath>()
    private let expandedIndexPathRelay = BehaviorRelay<Set<IndexPath>>(value: []) // 확장된 셀 인덱스 관리
    private let deleteWorkplaceBtnRelay = PublishRelay<String>()

    private lazy var input = HomeViewModel.Input(
        viewDidLoad: viewDidLoadRelay.asObservable(),
        refreshBtnTapped: refreshBtnTappedRelay.asObservable(),
        cellTapped: cellTappedRelay.asObservable(),
        deleteWorkplaceBtnTapped: deleteWorkplaceBtnRelay.asObservable()
    )
    private lazy var output = homeViewModel.transform(input: input)

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<HomeTableViewFirstSection> (
        configureCell: {
            [weak self] dataSource,
            tableView,
            indexPath,
            item in
            switch item {
            case .workplace(let info):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyWorkSpaceCell.identifier,
                    for: indexPath
                ) as? MyWorkSpaceCell else {
                    return UITableViewCell()
                }
                let isExpanded = self?.expandedIndexPathRelay.value.contains(indexPath) ?? false
                cell.update(with: info, isExpanded: isExpanded, menuActions: createWorkspaceMenuActions(with: info))
                
                return cell
            case .store(let info):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyStoreCell.identifier,
                    for: indexPath
                ) as? MyStoreCell else {
                    return UITableViewCell()
                }
                cell.update(with: info, menuActions: createStoreMenuActions(with: info)) // TODO: - 실제 데이터 바인딩
                self?.inviteCode = info.inviteCode
                return cell
            }
            
            // MARK: - 셀 내 메뉴에 대한 Action 정의
            func createWorkspaceMenuActions(with info: WorkplaceCellInfo) -> [UIAction] { // TODO: - 실제 수정 삭제가 이뤄질 시 과정에 필요한 데이터 입력
                let editAction = UIAction(title: "수정하기") { [weak self] _ in
                    print("근무지 수정")
                    guard let self else { return }
                    let vc = WorkerWorkplaceRegistrationViewController(
                        workplaceId: info.id,
                        isRegisterMode: false,
                        isEdit: true,
                        isHideWorkplaceInfoViewArrow: false,
                        // 공유 근무지일 경우 초대받아 등록된 입장이므로 이름, 카테고리 고정
                        mode: .fullRegistration,
                        nameValue: info.storeName,
                        categoryValue: info.category,
                        salaryTypeValue: info.workerDetail?.wageCalcMethod ?? "매월",
                        salaryCalcValue: info.workerDetail?.wageType ?? "고정",
                        fixedSalaryValue: String(info.workerDetail?.wage ?? 0),
                        hourlyWageValue: String(info.workerDetail?.wage ?? 0),
                        payDateValue: String(info.workerDetail?.payDay ?? 0) + "일",
                        payWeekdayValue: info.workerDetail?.payWeekday ?? "금",
                        isFourMajorSelected: info.workerDetail?.employmentInsurance ?? false,
                        isNationalPensionSelected: info.workerDetail?.nationalPension ?? false,
                        isHealthInsuranceSelected: info.workerDetail?.healthInsurance ?? false,
                        isEmploymentInsuranceSelected: info.workerDetail?.employmentInsurance ?? false,
                        isIndustrialAccidentInsuranceSelected: info.workerDetail?.industrialAccident ?? false,
                        isIncomeTaxSelected: info.workerDetail?.incomeTax ?? false,
                        isWeeklyAllowanceSelected: info.workerDetail?.weeklyAllowance ?? false,
                        isNightAllowanceSelected: info.workerDetail?.nightAllowance ?? false,
                        labelTitle: info.labelTitle,
                        showDot: info.showDot,
                        dotColor: LabelColorString(rawValue: info.dotColor)?.labelColor
                    )
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let deleteAction = UIAction(title: "삭제하기", attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.deleteWorkplaceBtnRelay.accept(info.id)
                }

                return [editAction, deleteAction]
            }

            func createStoreMenuActions(with info: StoreCellInfo) -> [UIAction] { // TODO: - 실제 수정 삭제가 이뤄질 시 과정에 필요한 데이터 입력
                let editAction = UIAction(title: "수정하기") { [weak self] _ in
                    print("매장 수정")
                    guard let self else { return }
                    let vc = OwnerWorkplaceEditViewController(
                        workPlaceID: info.id,
                        nameValue: info.storeName,
                        categoryValue: info.category,
                        labelTitle: info.labelTitle,
                        showDot: info.showDot,
                        dotColor: LabelColorString(rawValue: info.dotColor)?.labelColor
                    )
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let deleteAction = UIAction(title: "삭제하기", attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.deleteWorkplaceBtnRelay.accept(info.id)
                }
                let copyInviteCode = UIAction(title: "초대 코드 보내기") { [weak self] _ in
                    guard let self = self,
                          let inviteCode = self.inviteCode else { return }
                    let shareInviteCodeVC = ShareInviteCodeViewController(inviteCode: inviteCode)
                    shareInviteCodeVC.modalPresentationStyle = .overFullScreen
                    shareInviteCodeVC.modalTransitionStyle = .crossDissolve
                    self.present(shareInviteCodeVC, animated: true, completion: nil)
                }

                return [editAction, copyInviteCode, deleteAction]
            }
        }
    )
    
    private var inviteCode: String?

    // MARK: - LoadView
    override func loadView() {
        view = homeView
    }

    // MARK: - Initializer
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !OnboardingManager.hasSeenOnboardingHome {
            // userType을 구독하고 값을 받은 후 온보딩 표시
            output.userType
                .skip(1)
                .take(1) 
                .subscribe(onNext: { [weak self] userType in
                    self?.showOnboarding(userType: userType)
                })
                .disposed(by: disposeBag)
        }
    }
}

private extension HomeViewController {
    func configure() {
        setStyles()
        setBindings()
    }

    func setStyles() {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
    }

    func setBindings() {
        homeView.rx.setDelegate
            .onNext(self)
        homeView.rx.bindItems
            .onNext((output.sectionData, dataSource))

        let selectedIndexPath = homeView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.homeView.rx.deselectRow.onNext(indexPath)
            })
            .share()
        
        selectedIndexPath
            .bind(to: cellTappedRelay)
            .disposed(by: disposeBag)
        
        // HomeView 버튼 이벤트 바인딩
        homeView.rx.refreshButtonTapped
            .do (onNext: { _ in
                print("로딩 시작됨")
            })
            .bind(to: refreshBtnTappedRelay)
            .disposed(by: disposeBag)


        // ViewModel의 Output을 ViewController의 상태에 반영
        output.expandedIndexPath
            .bind(to: expandedIndexPathRelay)
            .disposed(by: disposeBag)

        // 상태 변경 시 테이블뷰 리로드
        expandedIndexPathRelay.skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                let visibleRows = self.homeView.rx.indexPathsForVisibleRows
                if !visibleRows.isEmpty {
                    self.homeView.rx.reloadRows.onNext(visibleRows)
                }
            })
            .disposed(by: disposeBag)

        viewDidLoadRelay.accept(())
    }

    func makeManageRoutineViewController(type: RoutineType) -> ManageRoutineViewController {
        let routineUseCase = RoutineUseCase(repository: RoutineRepository(service: RoutineService()))
        let viewModel = ManageRoutineViewModel(type: type, routineUseCase: routineUseCase)
        return ManageRoutineViewController(routineType: type, viewModel: viewModel)
    }

    func showOnboarding(userType: UserType) {
        let vc = HomeOnboardingViewController(userType: userType)
        vc.modalPresentationStyle = .overFullScreen

        self.present(vc, animated: false)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeHeaderView.identifier) as? HomeHeaderView else {
            return UIView()
        }

        Observable.combineLatest(output.headerData, output.userType)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { headerData, userType in
                print("headerData: \(headerData)")
                print("구독 실행, ID: \(UUID().uuidString.prefix(8))")
                headerView.update(with: headerData, userType: userType)
            }) // TODO: - viewForHeaderInSection 다중 호출 특성으로 인한 다중 구독 해결
            .disposed(by: disposeBag)

        // headerView 내 액션 정의
        headerView.rx.todaysRoutineCardTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let vc = self.makeManageRoutineViewController(type: .today) // 추가 params 입력을 통해 오늘 or 전체 여부 분기
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        headerView.rx.allRoutineCardTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let vc = self.makeManageRoutineViewController(type: .all)
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        headerView.rx.plusButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self,
                      self.presentedViewController == nil else { return }
                let workplaceAddModalVC = WorkplaceAddModalViewController()
                let nav = UINavigationController(rootViewController: workplaceAddModalVC)
                nav.modalPresentationStyle = .overFullScreen
                nav.modalTransitionStyle = .crossDissolve
                self.present(nav, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        return headerView
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 340
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}

