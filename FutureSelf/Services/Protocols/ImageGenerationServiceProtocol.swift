//  ImageGenerationServiceProtocol.swift
import Foundation

protocol ImageGenerationServiceProtocol {
    /// Generate all 3 status variations at once
    func generateAllStatusVariations(
        for goal: Goal,
        userPhoto: Data?
    ) async throws -> FutureVision

    /// Get mock placeholder image for MVP
    func getMockImage(for goalType: GoalType, status: BudgetStatus) -> Data
}
