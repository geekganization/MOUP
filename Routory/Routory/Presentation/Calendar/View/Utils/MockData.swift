//
//  MockData.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

import Foundation

let calendarEventMockList = [
    CalendarEvent(id: "41KfzzHijbRcrmaq6XPp", title: "테스트이벤트", eventDate: "2025년 6월 8일", startTime: "09:00", endTime: "19:00", createdBy: "qW04Z01bzttiy2a6RQZ8", year: 2025, month: 6, day: 8, routineIds: ["6CdUWL27fcXbbAWd5mUN"]),
    CalendarEvent(id: "41KfzzHijbRcrmaq6XPp", title: "테스트이벤트", eventDate: "2025년 6월 9일", startTime: "09:00", endTime: "20:00", createdBy: "qW04Z01bzttiy2a6RQZ8", year: 2025, month: 6, day: 9, routineIds: ["6CdUWL27fcXbbAWd5mUN"]),
    CalendarEvent(id: "41KfzzHijbRcrmaq6XPp", title: "테스트이벤트", eventDate: "2025년 6월 9일", startTime: "20:00", endTime: "21:00", createdBy: "qW04Z01bzttiy2a6RQZ8", year: 2025, month: 6, day: 9, routineIds: ["6CdUWL27fcXbbAWd5mUN"]),
    CalendarEvent(id: "41KfzzHijbRcrmaq6XPp", title: "테스트이벤트", eventDate: "2025년 6월 9일", startTime: "09:00", endTime: "19:00", createdBy: "qW04Z01bzttiy2a6RQZ8", year: 2025, month: 6, day: 9, routineIds: ["6CdUWL27fcXbbAWd5mUN"])
]

let routineMock = Routine(id: "6CdUWL27fcXbbAWd5mUN", routineName: "테스트루틴", alarmTime: "17:00", tasks: ["출입문 열기", "전등 켜기"])

let userMock = User(userName: "테스트알바사용자", role: "worker", workplaceList: [])

let userWockplaceMock = UserWorkplace(color: "red")

let workCalendarMock = WorkCalendar(id: "OmmrDGDlYTieatajVeKF", calendarName: "테스트캘린더", isShared: false, ownerId: "qW04Z01bzttiy2a6RQZ8", workplaceId: "0Ypaah18isj0cFTgyZtj", sharedWith: [""])

let workerDetailMock = WorkerDetail(id: "qW04Z01bzttiy2a6RQZ8", workerName: "테스트알바", wage: 10500, wageCalcMethod: "hourly", wageType: "monthly", weeklyAllowance: false, payDay: 25, payWeekday: "", breakTimeMinutes: 60, employmentInsurance: true, healthInsurance: true, industrialAccident: true, nationalPension: true, incomeTax: true, nightAllowance: false)

let workplaceMock = Workplace(id: "0Ypaah18isj0cFTgyZtj", workplacesName: "테스트 근무지", category: "편의점", ownerId: "qW04Z01bzttiy2a6RQZ8", inviteCode: "", inviteCodeExpiresAt: "", isOfficial: false)
