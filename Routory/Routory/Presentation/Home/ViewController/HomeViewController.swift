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
    private let navigationRequestRelay = PublishRelay<Void>()

    private var headerCallCount = 0

    private lazy var input = HomeViewModel.Input(
        viewDidLoad: viewDidLoadRelay.asObservable(),
        refreshBtnTapped: refreshBtnTappedRelay.asObservable(),
        cellTapped: cellTappedRelay.asObservable()
    )
    private lazy var output = homeViewModel.transform(input: input)

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<HomeTableViewFirstSection> (
        configureCell: { [weak self] dataSource, tableView, indexPath, item in
            switch item {
            case .workplace(let dummy):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyWorkSpaceCell.identifier,
                    for: indexPath
                ) as? MyWorkSpaceCell else {
                    return UITableViewCell()
                }
                let isExpanded = self?.expandedIndexPathRelay.value.contains(indexPath) ?? false
                cell.update(with: dummy, isExpanded: isExpanded, menuActions: self?.createWorkspaceMenuActions() ?? [])

                return cell
            case .store(let dummy):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyStoreCell.identifier,
                    for: indexPath
                ) as? MyStoreCell else {
                    return UITableViewCell()
                }
                cell.update(with: dummy, menuActions: self?.createStoreMenuActions() ?? []) // TODO: - 실제 데이터 바인딩
                self?.inviteCode = dummy.inviteCode
                return cell
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
//                LoadingManager.start()
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
                self?.homeView.rx.reloadData.onNext(())
            })
            .disposed(by: disposeBag)

        viewDidLoadRelay.accept(())
    }

    // MARK: - 셀 내 메뉴에 대한 Action 정의
    func createWorkspaceMenuActions() -> [UIAction] { // TODO: - 실제 수정 삭제가 이뤄질 시 과정에 필요한 데이터 입력
//        let editAction = UIAction(title: "수정하기") { _ in
//            print("근무지 수정")
//        }
        let deleteAction = UIAction(title: "삭제하기", attributes: .destructive) { _ in
            print("근무지 삭제")
        }

        return [deleteAction]
    }

    func createStoreMenuActions() -> [UIAction] { // TODO: - 실제 수정 삭제가 이뤄질 시 과정에 필요한 데이터 입력
//        let editAction = UIAction(title: "수정하기") { _ in
//            print("매장 수정")
//            
//        }
        let deleteAction = UIAction(title: "삭제하기", attributes: .destructive) { _ in
            print("매장 삭제")
        }
        let copyInviteCode = UIAction(title: "초대 코드 보내기") { [weak self] _ in
            guard let self = self,
                  let inviteCode = self.inviteCode else { return }
            let shareInviteCodeVC = ShareInviteCodeViewController(inviteCode: inviteCode)
            shareInviteCodeVC.modalPresentationStyle = .overFullScreen
            shareInviteCodeVC.modalTransitionStyle = .crossDissolve
            self.present(shareInviteCodeVC, animated: true, completion: nil)
        }

        return [deleteAction, copyInviteCode]
    }

    func makeManageRoutineViewController(type: RoutineType) -> ManageRoutineViewController {
        let routineUseCase = RoutineUseCase(repository: RoutineRepository(service: RoutineService()))
        let viewModel = ManageRoutineViewModel(type: type, routineUseCase: routineUseCase)
        return ManageRoutineViewController(routineType: type, viewModel: viewModel)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerCallCount += 1
        print("🔥 viewForHeaderInSection 호출됨 - \(headerCallCount)번째")
        print("🔥🔥🔥 헤더 호출 - 시간: \(Date())")

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeHeaderView.identifier) as? HomeHeaderView else {
            return UIView()
        }

        Observable.combineLatest(output.headerData, output.userType)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { headerData, userType in
                print("headerData: \(headerData)")
                headerView.update(with: headerData, userType: userType)
            })
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
            .subscribe(onNext: {
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

