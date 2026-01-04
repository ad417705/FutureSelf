//
//  User.swift
//  FutureSelf
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var displayName: String
    var incomeType: IncomeType
    var primaryPayCycle: PayCycle
    var monthlyIncome: Decimal?
    var onboardingComplete: Bool
    var profilePhotoData: Data?              // User's profile photo (base64 encoded)
    var onboardingPhotoCollected: Bool       // Track photo collection
    var hasCompletedGoalOnboarding: Bool     // Track goal "why" completion
    var settings: UserSettings
    var createdAt: Date

    enum IncomeType: String, Codable, CaseIterable {
        case steady, irregular, mixed
        var displayName: String {
            switch self {
            case .steady: return "Steady Income"
            case .irregular: return "Irregular Income"
            case .mixed: return "Mixed Income"
            }
        }
    }

    enum PayCycle: String, Codable, CaseIterable {
        case weekly, biweekly, twiceMonthly, monthly, irregular
        var displayName: String {
            switch self {
            case .weekly: return "Weekly"
            case .biweekly: return "Bi-weekly"
            case .twiceMonthly: return "Twice Monthly"
            case .monthly: return "Monthly"
            case .irregular: return "Irregular"
            }
        }
    }
}

struct UserSettings: Codable {
    var voiceModeEnabled: Bool
    var highContrastMode: Bool
    var notificationsEnabled: Bool
    var triageModeActive: Bool
    var currency: String

    static var `default`: UserSettings {
        UserSettings(
            voiceModeEnabled: false,
            highContrastMode: false,
            notificationsEnabled: true,
            triageModeActive: false,
            currency: "USD"
        )
    }
}
