//
//  EventTableView.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import UIKit

final class EventTableView: UITableView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.register(EventCell.self, forCellReuseIdentifier: EventCell.identifier)
        self.rowHeight = 68
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}
