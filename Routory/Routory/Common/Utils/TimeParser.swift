//
//  TimeParser.swift
//  Routory
//
//  Created by 송규섭 on 6/26/25.
//

import Foundation

final class TimeParser {
    static let shared = TimeParser()

    func parseToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 0
        }

        return hour * 60 + minute
    }

    func parseToTimeString(_ minutes: Int) -> String {
        let hour = String(format: "%02d", minutes / 60)
        let minute = String(format: "%02d", minutes % 60)

        return "\(hour)시간 \(minute)분"
    }
}
