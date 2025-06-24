//
//  CalendarEventListVCDelegate.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import Foundation

protocol CalendarEventListVCDelegate: AnyObject {
    /// `eventTableView`의 셀을 탭했을 때 호출하는 메서드
    func didTapEventCell(model: CalendarModel)
    /// `assignButton`을 탭했을 때 호출하는 메서드
    func didTapAssignButton()
    /// 제스처에 의해 `dismiss`될 때 호출하는 메서드
    func presentationControllerDidDismiss()
}
