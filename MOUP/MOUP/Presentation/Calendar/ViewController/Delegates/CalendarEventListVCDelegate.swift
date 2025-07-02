//
//  CalendarEventListVCDelegate.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import Foundation

protocol CalendarEventListVCDelegate: AnyObject {
    /// `EventCell`을 탭했을 때 호출되는 메서드
    func didTapEventCell(model: CalendarModel)
    /// `EventCell` 내부 메뉴의 수정하기 버튼을 탭했을 때 호출되는 메서드
    func didTapEditMenu(model: CalendarModel)
    /// `registerButton`을 탭했을 때 호출되는 메서드
    func didTapRegisterButton()
    /// 근무가 삭제되었을 때 호출되는 메서드
    func didDeleteEvent()
    /// 제스처에 의해 `dismiss`될 때 호출되는 메서드
    func presentationControllerDidDismiss()
}
