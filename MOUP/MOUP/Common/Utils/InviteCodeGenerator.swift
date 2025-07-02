//
//  InviteCodeGenerator.swift
//  Routory
//
//  Created by shinyoungkim on 6/19/25.
//

import Foundation
import CryptoKit
import BigInt

/// 초대코드를 생성하는 유틸리티 클래스.
/// - SHA256 해시와 Base62 인코딩을 사용하여 고유한 6자리 코드를 생성합니다.
/// - 중복 체크 없이도 코드 충돌 가능성이 매우 낮으며, 가독성과 입력 편의성을 고려해 설계되었습니다.
final class InviteCodeGenerator {
    
    /// 사용 가능한 문자 집합 (Base62에서 소문자 제외)
    /// - 대문자 A–Z (26자)
    /// - 숫자 0–9 (10자)
    /// → 총 36자
    private static let charset = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    
    /// 초대코드를 생성합니다.
    /// - Parameters:
    ///   - userID: 사용자 식별자 (ex: UUID, 사용자 ID 등)
    ///   - timestamp: 생성 기준 시간 (기본값은 현재 시각). 동일 userID로 여러 코드를 만들고 싶을 때 사용
    ///   - length: 코드 길이 (기본값은 6자리)
    /// - Returns: Base62 문자로 구성된 고유 초대코드
    static func generate(userID: String, timestamp: Date = Date(), length: Int = 6) -> String {
        // 1. userID와 타임스탬프를 결합해 유일한 문자열 생성
        let timestampString = formattedTimestamp(from: timestamp)
        let input = userID + timestampString
        
        // 2. SHA256 해시로 예측 불가능한 해시값 생성
        let hash = SHA256.hash(data: Data(input.utf8))
        
        // 3. 해시를 Base62 문자열로 변환
        let base62 = base62Encode(hash)
        
        // 4. 앞에서부터 지정된 길이만큼 코드 추출 (예: 6자리)
        return String(base62.prefix(length))
    }
    
    /// 현재 시간을 yyyyMMddHHmmss 형식의 문자열로 변환
    /// - 예: 20250619174230
    /// - 초 단위까지 포함하여 같은 userID로 여러 번 생성해도 중복되지 않도록 함
    private static func formattedTimestamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: date)
    }
    
    /// SHA256 해시를 Base62 문자로 인코딩합니다.
    /// - 해시값을 정수(BigUInt)로 변환 후, 36진수 문자 집합으로 나누어 코드 생성
    private static func base62Encode(_ hash: SHA256.Digest) -> String {
        // 256비트 해시를 정수로 변환
        var number = BigUInt(Data(hash))
        var result = ""
        // 여기서는 36
        let base = BigUInt(charset.count)

        // number를 base(36)로 나누며 각 자리를 문자로 치환
        while number > 0 {
            let (quotient, remainder) = number.quotientAndRemainder(dividingBy: base)
            let index = Int(remainder)
            let character = charset[index]
            // 앞쪽에 삽입 (가장 큰 자리수부터)
            result.insert(character, at: result.startIndex)
            number = quotient
        }

        return result
    }
}
