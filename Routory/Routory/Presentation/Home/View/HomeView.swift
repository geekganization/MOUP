import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class HomeView: UIView {
    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()

    // MARK: - UI Components
    private let homeNavigationBar = UIView().then {
        $0.backgroundColor = .systemBackground
    }

    private let logoImageView = UIImageView().then {
        $0.image = .textLogo
    }

    fileprivate let refreshButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .refresh.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        config.contentInsets = .init(top: 13.75, leading: 12.98, bottom: 13.75, trailing: 12.98)
        $0.configuration = config
    }
    
    fileprivate let notificationButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .bellWithDot
        config.contentInsets = .init(top: 13.75, leading: 12.98, bottom: 13.75, trailing: 12.98)
        $0.configuration = config
    }

    private let homeHeaderView = HomeHeaderView()
    
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(
            MyWorkSpaceCell.self,
            forCellReuseIdentifier: MyWorkSpaceCell.identifier
        )
        $0.register(
            MyStoreCell.self,
            forCellReuseIdentifier: MyStoreCell.identifier
        )
        $0.register(HomeHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeHeaderView.identifier)
        $0.separatorStyle = .none
        $0.backgroundColor = .systemBackground
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension HomeView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        addSubviews(homeNavigationBar, tableView)
        homeNavigationBar.addSubviews(logoImageView, refreshButton, notificationButton)
    }

    func setStyles() {
        backgroundColor = .systemBackground
    }

    func setConstraints() {
        homeNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }

        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(75)
            $0.height.equalTo(32)
        }

        refreshButton.snp.makeConstraints {
            $0.trailing.equalTo(notificationButton.snp.leading)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        notificationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(7)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(homeNavigationBar.snp.bottom)
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
    }
}

extension Reactive where Base: HomeView {
    var setDelegate: Binder<UITableViewDelegate> {
        Binder(base) { view, delegate in
            view.tableView.rx.setDelegate(delegate)
                .disposed(by: view.disposeBag)
        }
    }

    var bindItems: Binder<(Observable<[HomeTableViewFirstSection]>, RxTableViewSectionedReloadDataSource<HomeTableViewFirstSection>)> {
        Binder(base) { view, tuple in
            let (sections, dataSource) = tuple
            sections.bind(to: view.tableView.rx.items(dataSource: dataSource))
                .disposed(by: view.disposeBag)
        }
    }

    var itemSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }

    var deselectRow: Binder<IndexPath> {
        Binder(base) { view, indexPath in
            view.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var reloadData: Binder<Void> {
        Binder(base) { view, _ in
            view.tableView.reloadData()
        }
    }

    var reloadRows: Binder<[IndexPath]> {
        Binder(base) { view, indexPaths in
            view.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }

    var indexPathsForVisibleRows: [IndexPath] {
        return base.tableView.indexPathsForVisibleRows ?? []
    }

    var refreshButtonTapped: ControlEvent<Void> {
        return base.refreshButton.rx.tap
    }
    
    var notificationButtonTapped: ControlEvent<Void> {
        return base.notificationButton.rx.tap
    }
}
