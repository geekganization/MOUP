//
//  CalendarViewDelegate.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import Foundation

/// `CalendarView`의 Delegate
protocol CalendarViewDelegate: AnyObject {
    /// 연/월 선택 `jtaCalendar`의 셀을 탭했을 때 호출하는 메서드
    ///
    /// - Parameters:
    ///   - day: 탭한 셀의 일
    ///   - eventList: 탭한 셀의 일에 해당하는 `CalendarEvent` 배열
    func didSelectCell(day: Int, eventList: [CalendarEvent])
}
