//
//  InsuranceHelper.swift
//  Routory
//
//  Created by 송규섭 on 6/26/25.
//

import Foundation

struct InsuranceSettings {
    let hasEmploymentInsurance: Bool    // 고용보험 적용 여부
    let hasHealthInsurance: Bool        // 건강보험 적용 여부
    let hasIndustrialAccident: Bool     // 산재보험 적용 여부
    let hasNationalPension: Bool        // 국민연금 적용 여부
}

// 급여 계산 결과
typealias PayrollResult = (
    employmentInsurance: Int, // 고용보험
    healthInsurance: Int,     // 건강보험
    industrialAccident: Int,  // 산재보험
    nationalPension: Int,     // 국민연금
    incomeTax: Int,          // 소득세
    netPay: Int  // 실수령액
)

final class PayrollCalculator {
    static let shared = PayrollCalculator()

    private let employmentInsuranceRate = 0.009    // 0.9% (개인 부담분)
    private let healthInsuranceRate = 0.03545      // 3.545% (개인 부담분)
    private let industrialAccidentRate = 0.0045   // 0.45% (개인 부담분 - 실제론 회사부담이지만 계산용)
    private let nationalPensionRate = 0.045       // 4.5% (개인 부담분)

    // MARK: - 상한액 (월 기준)
    private let employmentInsuranceLimit = 2_680_000     // 고용보험 상한 (268만원)
    private let healthInsuranceLimit = 3_000_000         // 건강보험 상한 (300만원)
    private let nationalPensionLimit = 5_690_000         // 국민연금 상한 (569만원)

    // MARK: - 소득세 기준
    private let incomeTaxFreeLimit = 2_090_000           // 월 209만원 이하 면세
    private let incomeTaxRate = 0.033                    // 3.3% (소득세 3% + 지방소득세 0.3%)

    func calculatePay(grossPay: Int, settings: InsuranceSettings) -> PayrollResult {
        // 각종 공제액 계산
        let employmentInsurance = settings.hasEmploymentInsurance ?
        calculateEmploymentInsurance(grossPay: grossPay) : 0

        let healthInsurance = settings.hasHealthInsurance ?
        calculateHealthInsurance(grossPay: grossPay) : 0

        let industrialAccident = settings.hasIndustrialAccident ?
        calculateIndustrialAccident(grossPay: grossPay) : 0

        let nationalPension = settings.hasNationalPension ?
        calculateNationalPension(grossPay: grossPay) : 0

        let incomeTax = calculateIncomeTax(grossPay: grossPay)

        // 실수령액 계산
        let totalDeductions = employmentInsurance + healthInsurance +
        industrialAccident + nationalPension + incomeTax
        let netPay = grossPay - totalDeductions

        return (
            employmentInsurance: employmentInsurance,
            healthInsurance: healthInsurance,
            industrialAccident: industrialAccident,
            nationalPension: nationalPension,
            incomeTax: incomeTax,
            netPay: netPay
        )
    }

    /// 고용보험 계산
    private func calculateEmploymentInsurance(grossPay: Int) -> Int {
        let taxableAmount = min(grossPay, employmentInsuranceLimit)
        return Int(Double(taxableAmount) * employmentInsuranceRate)
    }

    /// 건강보험 계산
    private func calculateHealthInsurance(grossPay: Int) -> Int {
        let taxableAmount = min(grossPay, healthInsuranceLimit)
        return Int(Double(taxableAmount) * healthInsuranceRate)
    }

    /// 산재보험 계산
    private func calculateIndustrialAccident(grossPay: Int) -> Int {
        return Int(Double(grossPay) * industrialAccidentRate)
    }

    /// 국민연금 계산
    private func calculateNationalPension(grossPay: Int) -> Int {
        let taxableAmount = min(grossPay, nationalPensionLimit)
        return Int(Double(taxableAmount) * nationalPensionRate)
    }

    /// 소득세 계산
    private func calculateIncomeTax(grossPay: Int) -> Int {
        if grossPay <= incomeTaxFreeLimit {
            return 0
        } else {
            let taxableAmount = grossPay - incomeTaxFreeLimit
            return Int(Double(taxableAmount) * incomeTaxRate)
        }
    }
}
