//  OnboardingProgress.swift
import Foundation

struct OnboardingProgress: Codable {
    var currentStep: OnboardingStep
    var completedSteps: Set<OnboardingStep>
    var collectedData: OnboardingData

    enum OnboardingStep: String, Codable, CaseIterable {
        case welcome
        case profilePhoto
        case goalSelection
        case goalDetails
        case goalWhy
        case visualization
        case complete
    }
}

struct OnboardingData: Codable {
    var profilePhoto: Data?
    var goalType: GoalType?
    var goalName: String?
    var goalDescription: String?
    var targetAmount: Decimal?
    var targetDate: Date?
    var detailedWhy: String?
    var goalDetails: GoalDetails?

    init() {
        self.profilePhoto = nil
        self.goalType = nil
        self.goalName = nil
        self.goalDescription = nil
        self.targetAmount = nil
        self.targetDate = nil
        self.detailedWhy = nil
        self.goalDetails = nil
    }
}
