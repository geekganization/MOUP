//
//  WorkplaceInfoInput.swift
//  Routory
//
//  Created by shinyoungkim on 6/28/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceInfoInput: UIView {
    
    // MARK: - Properties
    
    private let sections: [[String]] = [
        ["이름", "카테고리"],
        ["급여 유형", "급여 계산", "고정급", "급여일"],
        ["4대 보험", "국민연금", "건강보험", "고용보험", "산재보험", "소득세", "주휴수당", "야간수당"],
        ["빨간색"]
    ]
    
    private let inputValues: [IndexPath: (text: String, showsArrow: Bool)] = [
        IndexPath(item: 0, section: 0): ("GS25 분당이매역점", false),
        IndexPath(item: 1, section: 0): ("편의점", false),
        
        IndexPath(item: 0, section: 1): ("매월", true),
        IndexPath(item: 1, section: 1): ("고정", true),
        IndexPath(item: 2, section: 1): ("1,000,000원", false),
        IndexPath(item: 3, section: 1): ("25일", false)
    ]
    
    private var selectedConditions: Set<String> = []
    
    private let groupedConditions: [String: [String]] = [
        "4대 보험": ["4대 보험", "국민연금", "건강보험", "고용보험", "산재보험"]
    ]
    
    // MARK: - UI Components
    
    private let navigationBar = MyPageNavigationBar(title: "GS25 분당이매역점")
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    ).then {
        $0.dataSource = self
        $0.register(
            InputRowCell.self,
            forCellWithReuseIdentifier: InputRowCell.identifier
        )
        $0.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
//        $0.register(
//            SectionFooterView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
//            withReuseIdentifier: SectionFooterView.identifier
//        )
    }
    
//    private let conditionNoticeLabel = UILabel().then {
//        $0.text = "* 오후 10시 이후 야간수당을 받는 경우 체크해주세요"
//        $0.font = .bodyMedium(12)
//        $0.textColor = .gray700
//    }
    
    private let completeButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "입력완료"
        config.baseForegroundColor = .gray500
        config.baseBackgroundColor = .gray300
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSemibold(18)
            return outgoing
        }

        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        guard
//            let layout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout,
//            let attributes = layout.layoutAttributesForDecorationView(
//                ofKind: "SectionBackground",
//                at: IndexPath(item: 0, section: 2)
//            )
//        else { return }
//
//        let backgroundFrame = attributes.frame
//
//        conditionNoticeLabel.snp.remakeConstraints {
//            $0.top.equalToSuperview().offset(backgroundFrame.maxY + 4)
//            $0.trailing.equalToSuperview()
//        }
//    }
}

private extension WorkplaceInfoInput {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            collectionView,
//            conditionNoticeLabel,
            completeButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(48)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(completeButton.snp.top).offset(-12)
        }
        
//        conditionNoticeLabel.snp.makeConstraints {
//            $0.top.equalTo(collectionView.snp.bottom).offset(-60)
//            $0.trailing.equalToSuperview().inset(16)
//        }
        
        completeButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(48)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 12, leading: 0, bottom: 12, trailing: 0
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: itemSize.heightDimension
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)

            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 12,
                trailing: 16
            )
            section.interGroupSpacing = 0

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(48)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            let background = NSCollectionLayoutDecorationItem.background(elementKind: "SectionBackground")
            background.contentInsets = NSDirectionalEdgeInsets(
                top: 48,
                leading: 16,
//                bottom: sectionIndex == 2 ? 30 : 12,
                bottom: 12,
                trailing: 16
            )
            background.zIndex = -1
            section.decorationItems = [background]
            
//            let footerSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .estimated(18)
//            )
//            let footer = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: footerSize,
//                elementKind: UICollectionView.elementKindSectionFooter,
//                alignment: .bottom
//            )
            
//            var boundaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = [header]
//            
//            if sectionIndex == 2 {
//                boundaryItems.append(footer)
//            }
            
//            section.boundarySupplementaryItems = boundaryItems

            return section
        }

        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: "SectionBackground")
        return layout
    }
}

extension WorkplaceInfoInput: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: InputRowCell.identifier,
            for: indexPath
        ) as? InputRowCell else {
            return UICollectionViewCell()
        }

        let title = sections[indexPath.section][indexPath.item]
        let (text, arrow) = inputValues[indexPath] ?? ("", false)

        let isPayday = (title == "급여일")
        
        let showsCheckbox = indexPath.section == 2

        cell.update(
            with: title,
            content: text,
            showsArrow: arrow,
            isPayday: isPayday,
            showsCheckbox: showsCheckbox,
            checked: selectedConditions.contains(title)
        )
        
        cell.onCheckToggled = { [weak self] isChecked in
            guard let self else { return }
            
            let titlesToUpdate = self.groupedConditions[title] ?? [title]
            
            for item in titlesToUpdate {
                if isChecked {
                    self.selectedConditions.insert(item)
                } else {
                    self.selectedConditions.remove(item)
                }
            }
            
            self.collectionView.reloadSections(
                IndexSet(integer: indexPath.section)
            )
        }

        let isLast = indexPath.item == sections[indexPath.section].count - 1
        cell.setIsLastCell(isLast)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return sections[section].count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.identifier,
                for: indexPath
            ) as! SectionHeaderView
            
            let titles: [Int: (String, Bool)] = [
                0: ("근무지", true),
                1: ("급여", true),
                2: ("근무 조건", true),
                3: ("라벨", false)
            ]
            let (title, highlight) = titles[indexPath.section] ?? ("", false)
            header.setTitle(title, highlightAsterisk: highlight)
            return header
            //        } else if kind == UICollectionView.elementKindSectionFooter, indexPath.section == 2 {
            //            let footer = collectionView.dequeueReusableSupplementaryView(
            //                ofKind: kind,
            //                withReuseIdentifier: SectionFooterView.identifier,
            //                for: indexPath
            //            ) as! SectionFooterView
            //            return footer
            //        }
        }

        return UICollectionReusableView()
    }
}
