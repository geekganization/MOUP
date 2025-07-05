//
//  InputSelectionViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class InputSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let selectionItems: [String]
    private var selectedCell: InputSelectionCell?
    private var selectedTitle: String?
    let completeRelay = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let navigationBar: BaseNavigationBar
    
    private let guideMessageLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
    }
    
    private let cell = InputSelectionCell(title: "매월").then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    private let completeButton = BaseButton(title: "완료").then {
        $0.isEnabled = false
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // MARK: - Initializer
    
    init(navigationTitle: String, guideMessage: String, selectionItems: [String]) {
        self.navigationBar = BaseNavigationBar(title: navigationTitle)
        self.guideMessageLabel.text = guideMessage
        self.selectionItems = selectionItems
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension InputSelectionViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setSelectionCells()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(
            navigationBar,
            guideMessageLabel,
            stackView,
            completeButton
        )
    }
    
    func setSelectionCells() {
        selectionItems.forEach { item in
            let cell = InputSelectionCell(title: item).then {
                $0.snp.makeConstraints { $0.height.equalTo(48) }
                $0.backgroundColor = .white
                $0.layer.cornerRadius = 12
                $0.layer.masksToBounds = true
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.gray400.cgColor
            }
            
            cell.tapRelay
                .subscribe(onNext: { [weak self] title in
                    self?.updateSelection(to: cell)
                    self?.selectedTitle = title
                })
                .disposed(by: disposeBag)

            stackView.addArrangedSubview(cell)
        }
    }
    
    func updateSelection(to selected: InputSelectionCell) {
        for case let item as InputSelectionCell in stackView.arrangedSubviews {
            item.setSelected(item == selected)
        }

        selectedCell = selected
        completeButton.isEnabled = true
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(48)
        }
        
        guideMessageLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(guideMessageLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        completeButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let title = self?.selectedTitle else {
                    print("선택된 타이틀이 없습니다.")
                    return
                }
                self?.completeRelay.accept(title)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
