//  AppContainer.swift
//  FutureSelf
//

import Foundation
import Combine

@MainActor
class AppContainer: ObservableObject {
    static let shared = AppContainer()

    @Published var currentUser: User

    let envelopeService: EnvelopeServiceProtocol
    let transactionService: TransactionServiceProtocol
    let goalService: GoalServiceProtocol
    let streakService: StreakServiceProtocol
    let aiService: AIServiceProtocol
    let imageGenerationService: ImageGenerationServiceProtocol

    private init() {
        let userId = "demo-user-001"
        
        self.currentUser = User(
            id: userId,
            email: "demo@futureself.app",
            displayName: "Jordan",
            incomeType: .irregular,
            primaryPayCycle: .biweekly,
            monthlyIncome: 3000,
            onboardingComplete: false,  // Start with onboarding for demo
            profilePhotoData: nil,
            onboardingPhotoCollected: false,
            hasCompletedGoalOnboarding: false,
            settings: UserSettings.default,
            createdAt: Date()
        )

        let envelopeSvc = MockEnvelopeService(userId: userId)
        let transactionSvc = MockTransactionService(userId: userId)
        let goalSvc = MockGoalService(userId: userId)
        let streakSvc = MockStreakService(userId: userId)
        
        self.envelopeService = envelopeSvc
        self.transactionService = transactionSvc
        self.goalService = goalSvc
        self.streakService = streakSvc
        self.aiService = MockAIService(
            userId: userId,
            transactionService: transactionSvc,
            envelopeService: envelopeSvc,
            goalService: goalSvc
        )

        // MVP: Use mock service
        self.imageGenerationService = MockImageGenerationService()

        // Post-MVP: Swap to Azure
        // self.imageGenerationService = AzureImageGenerationService(
        //     endpoint: Configuration.azureEndpoint,
        //     apiKey: Configuration.azureAPIKey
        // )
    }
}
