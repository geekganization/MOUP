//
//  OnboardingManager.swift
//  Routory
//
//  Created by 송규섭 on 7/1/25.
//

import Foundation

class OnboardingManager {
    private static let hasSeenOnboardingHomeKey = "hasSeenOnboardingHome"

    static var hasSeenOnboardingHome: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSeenOnboardingHomeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingHomeKey)
        }
    }
}
