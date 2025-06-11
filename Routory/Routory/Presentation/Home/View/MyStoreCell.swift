//
//  MyStoreCell.swift
//  Routory
//
//  Created by 송규섭 on 6/11/25.
//

import UIKit

class MyStoreCell: UICollectionViewCell {
    static let identifier = "MyStoreCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, message: "storyboard is not been implemented.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}
