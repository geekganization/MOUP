//
//  MyPageMenuListView.swift
//  Routory
//
//  Created by shinyoungkim on 6/10/25.
//

import UIKit
import SnapKit

final class MyPageMenuListView: UIView {
    
    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var menuTableView: UITableView {
        return tableView
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
