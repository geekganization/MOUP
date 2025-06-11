//
//  YearMonthPickerVCDelegate.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

import Foundation

/// `YearMonthPickerViewController`의 `Delegate`
protocol YearMonthPickerVCDelegate: AnyObject {
    /// 연/월 선택 `yearMonthPickerView`에서 이동 버튼을 탭했을 때 호출하는 메서드
    ///
    /// - Parameters:
    ///   - year: 이동할 연도
    ///   - month: 이동할 월
    func didGotoButtonTapped(year: Int, month: Int)
}
