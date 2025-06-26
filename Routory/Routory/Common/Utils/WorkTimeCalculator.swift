//
//  TimeHelper.swift
//  Routory
//
//  Created by 송규섭 on 6/26/25.
//

import Foundation

class WorkTimeCalculator {
    static let shared = WorkTimeCalculator()

    private let nightStart = 1320 // 22:00
    private let nightEnd = 360
    private let minutesInDay = 1440

    func calculateWorkTime(start startMinutes: Int, end endMinutes: Int) -> (dayMinutes: Int, nightMinutes: Int) {

        var nightMinutes = 0

        if startMinutes <= endMinutes {
            nightMinutes = calculateSameDayNight(start: startMinutes, end: endMinutes)
        }
        else {
            nightMinutes = calculateOvernightNight(start: startMinutes, end: endMinutes)
        }

        let totalMinutes = calculateTotalMinutes(start: startMinutes, end: endMinutes)
        let dayMinutes = totalMinutes - nightMinutes

        return (dayMinutes: dayMinutes, nightMinutes: nightMinutes)
    }

    /// 같은 날 야간시간 계산 (새벽 00:00~06:00 + 밤 22:00~24:00)
    private func calculateSameDayNight(start: Int, end: Int) -> Int {
        var nightMinutes = 0

        if start < nightEnd {
            nightMinutes += min(end, nightEnd) - start
        }

        if end > nightStart {
            nightMinutes += end - max(start, nightStart)
        }

        return nightMinutes
    }

    /// 다음날까지 야간시간 계산
    private func calculateOvernightNight(start: Int, end: Int) -> Int {
        var nightMinutes = 0

        if start >= nightStart {
            nightMinutes += minutesInDay - start
        } else {
            nightMinutes += minutesInDay - nightStart
        }

        nightMinutes += min(end, nightEnd)

        return nightMinutes
    }

    /// 총 근무시간 계산
    func calculateTotalMinutes(start: Int, end: Int) -> Int {
        if start <= end {
            return end - start
        }
        else {
            return (minutesInDay - start) + end
        }
    }
}
