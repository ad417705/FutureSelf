//  MockImageGenerationService.swift
import Foundation

@MainActor
class MockImageGenerationService: ImageGenerationServiceProtocol {

    func generateAllStatusVariations(
        for goal: Goal,
        userPhoto: Data?
    ) async throws -> FutureVision {
        // Simulate API delay for realism
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Get base image for goal type
        let baseImage = getMockImage(for: goal.type, status: .good)

        // Apply filters to create status variations
        let warningImage = ImageFilterUtilities.applyStatusFilters(to: baseImage, status: .warning) ?? baseImage
        let dangerImage = ImageFilterUtilities.applyStatusFilters(to: baseImage, status: .danger) ?? baseImage

        return FutureVision(
            baseImageData: baseImage,
            warningImageData: warningImage,
            dangerImageData: dangerImage,
            generationPrompt: buildMockPrompt(goal: goal),
            lastGenerated: Date(),
            generatedBy: .mock
        )
    }

    func getMockImage(for goalType: GoalType, status: BudgetStatus) -> Data {
        // Try to load from Assets (will be added later)
        // For now, generate placeholder using ImageFilterUtilities
        return ImageFilterUtilities.generatePlaceholder(for: goalType) ?? Data()
    }

    private func buildMockPrompt(goal: Goal) -> String {
        // Build descriptive prompt for documentation/testing
        var prompt = "A person achieving their goal of \(goal.name): \(goal.description)"

        if let details = goal.goalDetails {
            if let location = details.location {
                prompt += " at \(location)"
            }
            if let item = details.specificItem {
                prompt += " with \(item)"
            }
        }

        return prompt
    }
}
