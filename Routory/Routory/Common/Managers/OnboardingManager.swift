//
//  OnboardingManager.swift
//  Routory
//
//  Created by 송규섭 on 7/1/25.
//

import Foundation

class OnboardingManager {
    
    // MARK: - Properties
    
    private static let hasSeenOnboardingHomeKey = "hasSeenOnboardingHome"
    private static let hasSeenOnboardingCalendarKey = "hasSeenOnboardingCalendar"

    static var hasSeenOnboardingHome: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSeenOnboardingHomeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingHomeKey)
        }
    }
    
    static var hasSeenOnboardingCalendar: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSeenOnboardingCalendarKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingCalendarKey)
        }
    }
}
