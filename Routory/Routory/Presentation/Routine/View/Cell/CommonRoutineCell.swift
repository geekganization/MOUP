//
//  CommonRoutineCell.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import UIKit

class CommonRoutineCell: UITableViewCell {
    static let identifier = "CommonRoutineCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}
