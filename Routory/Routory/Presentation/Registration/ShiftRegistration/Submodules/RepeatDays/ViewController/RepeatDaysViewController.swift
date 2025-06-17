//
//  RepeatDaysViewController.swift
//  Routory
//
//  Created by tlswo on 6/11/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

// MARK: - RepeatDaysViewController

final class RepeatDaysViewController: UIViewController {

    // MARK: - Properties

    private let days = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
    private var selectedDays = Set<Int>()

    var onSelectDays: (([String]) -> Void)?
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: "반복") //*2
    let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.text = "반복할 요일을 선택해주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }

    private let tableView = UITableView().then {
        $0.register(DayCell.self, forCellReuseIdentifier: DayCell.identifier)
        $0.separatorInset = .zero
        $0.rowHeight = 50
        $0.tableFooterView = UIView()
    }

    private let applyButton = UIButton(type: .system).then {
        $0.setTitle("적용하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.backgroundColor = UIColor(red: 1.0, green: 0.39, blue: 0.28, alpha: 1.0)
        $0.layer.cornerRadius = 12
    }

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupViews()
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        view.addSubview(navigationBar)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    private func setupConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(applyButton.snp.top).offset(-24)
        }

        applyButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(48)
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapApply() {
        let shortDayNames = ["일", "월", "화", "수", "목", "금", "토"]
        let selectedNames = selectedDays.sorted().map { shortDayNames[$0] }
        onSelectDays?(selectedNames)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension RepeatDaysViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayCell.identifier, for: indexPath) as? DayCell else {
            return UITableViewCell()
        }

        let day = days[indexPath.row]
        let isSelected = selectedDays.contains(indexPath.row)
        cell.configure(with: day, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedDays.contains(indexPath.row) {
            selectedDays.remove(indexPath.row)
        } else {
            selectedDays.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
