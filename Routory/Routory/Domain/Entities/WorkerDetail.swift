//
//  WorkerDetail.swift
//  Routory
//
//  Created by 양원식 on 6/9/25.
//

// MARK: - WorkerDetail

/// Firestore의 workplaces/{workplaceId}/worker/{userId} 문서에 대응되는 알바 정보 모델
struct WorkerDetail: Codable {

    /// 알바 이름 (표시용)
    let workerName: String

    /// 시급/고정급 (단위: 원)
    let wage: Int

    /// 급여 계산 방식 ("hourly", "monthly")
    let wageCalcMethod: String

    /// 급여 유형 (예: "시급제", "월급제")
    let wageType: String

    /// 주휴 수당 지급 여부
    let weeklyAllowance: Bool

    /// 급여일 (1~31)
    let payDay: Int

    /// 급여 요일 (예: "금요일")
    let payWeekday: String

    /// 휴게 시간 (단위: 분)
    let breakTimeMinutes: Int

    /// 4대 보험 - 고용보험 가입 여부
    let employmentInsurance: Bool
    /// 4대 보험 - 건강보험 가입 여부
    let healthInsurance: Bool
    /// 4대 보험 - 산재보험 가입 여부
    let industrialAccident: Bool
    /// 4대 보험 - 국민연금 가입 여부
    let nationalPension: Bool

    /// 소득세 납부 여부
    let incomeTax: Bool

    /// 야간 수당 지급 여부
    let nightAllowance: Bool
    
    /// 컬러
    let color: String

    init(workerName: String, wage: Int, wageCalcMethod: String, wageType: String, weeklyAllowance: Bool, payDay: Int, payWeekday: String, breakTimeMinutes: Int, employmentInsurance: Bool, healthInsurance: Bool, industrialAccident: Bool, nationalPension: Bool, incomeTax: Bool, nightAllowance: Bool, color: String) {
        self.workerName = workerName
        self.wage = wage
        self.wageCalcMethod = wageCalcMethod
        self.wageType = wageType
        self.weeklyAllowance = weeklyAllowance
        self.payDay = payDay
        self.payWeekday = payWeekday
        self.breakTimeMinutes = breakTimeMinutes
        self.employmentInsurance = employmentInsurance
        self.healthInsurance = healthInsurance
        self.industrialAccident = industrialAccident
        self.nationalPension = nationalPension
        self.incomeTax = incomeTax
        self.nightAllowance = nightAllowance
        self.color = color
    }
}

