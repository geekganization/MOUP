//
//  YearMonthPickerDelegate.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

import Foundation

/// `BasePickerViewController`의 Delegate
protocol YearMonthPickerDelegate: AnyObject {
    /// 연/월 선택 `yearMonthPickerView`에서 이동 버튼을 탭했을 때 호출되는 메서드
    ///
    /// - Parameters:
    ///   - year: 이동할 연도
    ///   - month: 이동할 월
    func didTapGotoButton(year: Int, month: Int)
}
