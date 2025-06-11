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
    private let homeHeaderView = HomeHeaderView()
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.register(
            HomeHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeHeaderView.identifier
        )
        $0.register(
            MyWorkSpaceCell.self,
            forCellWithReuseIdentifier: MyWorkSpaceCell.identifier
        )
        $0.register(
            MyStoreCell.self,
            forCellWithReuseIdentifier: MyStoreCell.identifier
        )
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

    // MARK: - Public Methods
}

private extension HomeView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(collectionView)
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .systemBackground
    }

    // MARK: - setConstraints
    func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension Reactive where Base: HomeView {
    var setDelegate: Binder<UICollectionViewDelegate> {
        Binder(base) { view, delegate in
            view.collectionView.rx.setDelegate(delegate)
                .disposed(by: view.disposeBag)
        }
    }

    var bindItems: Binder<(Observable<[HomeCollectionViewFirstSection]>, RxCollectionViewSectionedReloadDataSource<HomeCollectionViewFirstSection>)> {
        Binder(base) { view, tuple in
            let (sections, dataSource) = tuple
            sections.bind(to: view.collectionView.rx.items(dataSource: dataSource))
                .disposed(by: view.disposeBag)
        }
    }
}
