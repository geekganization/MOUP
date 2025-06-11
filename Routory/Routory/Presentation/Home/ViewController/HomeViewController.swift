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

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private let homeView = HomeView()
    private let homeViewModel: HomeViewModel
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let refreshBtnTappedRelay = PublishRelay<Void>()

    private let dataSource = RxCollectionViewSectionedReloadDataSource<HomeCollectionViewFirstSection> (
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .workplace(let dummy):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MyWorkSpaceCell.identifier,
                    for: indexPath
                ) as? MyWorkSpaceCell else {
                    return UICollectionViewCell()
                }
                return cell
            case .store(let dummy):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MyStoreCell.identifier,
                    for: indexPath
                ) as? MyStoreCell else {
                    return UICollectionViewCell()
                }
                return cell
            }
        },
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: HomeHeaderView.identifier,
                for: indexPath
            ) as? HomeHeaderView else {
                return UICollectionReusableView()
            }
            let section = dataSource[indexPath.section]
            headerView.update(with: section.header)
            return headerView
        }
    )

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

        viewDidLoadRelay.accept(())
        configure()
    }
}

private extension HomeViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }

    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .systemBackground
    }

    // MARK: - setBindings
    func setBindings() {
        let input = HomeViewModel.Input(
            viewDidLoad: viewDidLoadRelay,
            refreshBtnTapped: refreshBtnTappedRelay
        )
        let output = homeViewModel.transform(input: input)

        homeView.rx.setDelegate
            .onNext(self)
        homeView.rx.bindItems
            .onNext((output.sectionData, dataSource))
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 340)
    }
}
