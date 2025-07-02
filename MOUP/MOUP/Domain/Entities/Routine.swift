//
//  Routine.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - Routine

/// Firestore의 users/{userId}/routine/{routineId} 문서에 대응되는 루틴 모델
struct Routine: Codable {

    /// 루틴 이름
    let routineName: String

    /// 알림 시간 (예: "08:30")
    let alarmTime: String

    /// 루틴에 포함된 작업 목록
    let tasks: [String]

    init(routineName: String, alarmTime: String, tasks: [String]) {
        self.routineName = routineName
        self.alarmTime = alarmTime
        self.tasks = tasks
    }
}

struct RoutineItem {
    let routineInfo: RoutineInfo
    var isSelected: Bool
}

struct RoutineInfo {
    let id: String
    let routine: Routine
}
