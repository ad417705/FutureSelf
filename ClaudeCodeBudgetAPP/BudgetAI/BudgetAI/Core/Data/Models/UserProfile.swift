//
//  UserProfile.swift
//  BudgetAI
//
//  Created by Claude on 12/26/25.
//

import Foundation

struct UserProfile: Codable {
    var name: String
    var email: String
    var accountCreationDate: Date
    var profileImageData: Data? // For storing avatar image

    // Income preferences
    var hasVariableIncome: Bool
    var monthlyIncome: Double?

    // AI preferences
    var enablePredictiveAlerts: Bool
    var enableAISuggestions: Bool
    var aiSuggestionFrequency: SuggestionFrequency

    init(name: String = "", email: String = "", accountCreationDate: Date = Date(), profileImageData: Data? = nil, hasVariableIncome: Bool = false, monthlyIncome: Double? = nil, enablePredictiveAlerts: Bool = true, enableAISuggestions: Bool = true, aiSuggestionFrequency: SuggestionFrequency = .weekly) {
        self.name = name
        self.email = email
        self.accountCreationDate = accountCreationDate
        self.profileImageData = profileImageData
        self.hasVariableIncome = hasVariableIncome
        self.monthlyIncome = monthlyIncome
        self.enablePredictiveAlerts = enablePredictiveAlerts
        self.enableAISuggestions = enableAISuggestions
        self.aiSuggestionFrequency = aiSuggestionFrequency
    }
}

enum SuggestionFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var displayName: String {
        return self.rawValue
    }
}

// MARK: - UserDefaults Storage

extension UserProfile {
    private static let userProfileKey = "userProfile"

    static func load() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: userProfileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            // Return default profile if none exists
            let defaultProfile = UserProfile()
            defaultProfile.save()
            return defaultProfile
        }
        return profile
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: UserProfile.userProfileKey)
            print("✅ User profile saved")
        }
    }
}
