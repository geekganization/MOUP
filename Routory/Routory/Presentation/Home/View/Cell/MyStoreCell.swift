//
//  MyStoreCell.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import UIKit

class MyStoreCell: UITableViewCell {
    static let identifier = "MyStoreCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable, message: "storyboard is not been implemented.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}
