//  OnboardingCoordinator.swift
import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor
class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingProgress.OnboardingStep = .welcome
    @Published var progress: OnboardingProgress

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container

        // Try to load saved progress
        if let savedData = UserDefaults.standard.data(forKey: "onboardingProgress"),
           let savedProgress = try? JSONDecoder().decode(OnboardingProgress.self, from: savedData) {
            self.progress = savedProgress
            self.currentStep = savedProgress.currentStep
        } else {
            self.progress = OnboardingProgress(
                currentStep: .welcome,
                completedSteps: [],
                collectedData: OnboardingData()
            )
        }
    }

    func advance() {
        let allSteps = OnboardingProgress.OnboardingStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentStep),
           currentIndex < allSteps.count - 1 {
            progress.completedSteps.insert(currentStep)
            currentStep = allSteps[currentIndex + 1]
            progress.currentStep = currentStep
            saveProgress()

            // Haptic feedback for progression
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    func goBack() {
        let allSteps = OnboardingProgress.OnboardingStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentStep),
           currentIndex > 0 {
            currentStep = allSteps[currentIndex - 1]
            progress.currentStep = currentStep
            saveProgress()

            // Haptic feedback for going back
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
    }

    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: "onboardingProgress")
        }
    }

    func complete() async throws {
        // 1. Update user profile with photo
        var updatedUser = container.currentUser
        updatedUser.profilePhotoData = progress.collectedData.profilePhoto
        updatedUser.onboardingPhotoCollected = true
        updatedUser.hasCompletedGoalOnboarding = true
        updatedUser.onboardingComplete = true
        container.currentUser = updatedUser

        // 2. Create the goal
        let goal = Goal(
            userId: container.currentUser.id,
            name: progress.collectedData.goalName ?? "My Goal",
            description: progress.collectedData.goalDescription ?? "",
            type: progress.collectedData.goalType ?? .custom,
            targetAmount: progress.collectedData.targetAmount,
            currentAmount: 0,
            targetDate: progress.collectedData.targetDate,
            isActive: true,
            detailedWhy: progress.collectedData.detailedWhy,
            goalDetails: progress.collectedData.goalDetails
        )

        var enhancedGoal = goal

        // 3. Generate future vision
        let vision = try await container.imageGenerationService.generateAllStatusVariations(
            for: enhancedGoal,
            userPhoto: progress.collectedData.profilePhoto
        )
        enhancedGoal.futureVision = vision
        enhancedGoal.lastVisualizationUpdate = Date()

        // 4. Save goal
        _ = try await container.goalService.createGoal(enhancedGoal)

        // 5. Clear onboarding progress
        UserDefaults.standard.removeObject(forKey: "onboardingProgress")
    }
}
