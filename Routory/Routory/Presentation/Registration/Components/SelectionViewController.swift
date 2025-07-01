//
//  SelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import RxSwift

final class SelectionViewController<T>: UIViewController,UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate {

    struct Item {
        let title: String
        let icon: String?
        let value: T
    }

    private let titleText: String
    private let descriptionText: String
    private let items: [Item]
    private var selectedIndex: Int?

    var onSelect: ((T) -> Void)?
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: titleText)
    let disposeBag = DisposeBag()

    init(title: String, description: String, items: [Item], selected: T?) {
        self.titleText = title
        self.descriptionText = description
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let tableView = UITableView()
    private let doneButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
        $0.isEnabled = false
        $0.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupNavigationBar()
        updateDoneButtonState()
    }
    
    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        print("✅ setupUI 호출됨")
        let descriptionLabel = UILabel().then {
            $0.text = descriptionText
            $0.font = .headBold(18)
            $0.textColor = .gray900
            $0.numberOfLines = 0
        }

        tableView.do {
            $0.register(SelectableListCell.self, forCellReuseIdentifier: "SelectableListCell")
            $0.delegate = self
            $0.dataSource = self
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
            $0.rowHeight = 48
            $0.backgroundColor = .clear
            $0.contentInset = .zero
        }

        doneButton.do {
            $0.setTitle("완료", for: .normal)
            $0.titleLabel?.font = .buttonSemibold(18)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .primary500
            $0.layer.cornerRadius = 12
            $0.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        }

        view.addSubview(navigationBar)
        view.addSubview(descriptionLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(doneButton.snp.top).offset(-16)
        }

        doneButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(52)
        }
    }
    
    private func updateDoneButtonState() {
        let isSelected = selectedIndex != nil
        doneButton.isEnabled = isSelected
        doneButton.alpha = isSelected ? 1.0 : 0.5
    }

    @objc private func didTapDone() {
        guard let index = selectedIndex else { return }
        onSelect?(items[index].value)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableListCell", for: indexPath) as? SelectableListCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        let selected = indexPath.row == selectedIndex
        cell.configure(icon: item.icon, text: item.title, selected: selected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        updateDoneButtonState()
    }
}
