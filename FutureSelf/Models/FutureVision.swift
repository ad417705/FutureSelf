//  FutureVision.swift
import Foundation

struct FutureVision: Codable {
    var baseImageData: Data?           // AI-generated image (good status)
    var warningImageData: Data?        // Degraded version for warning
    var dangerImageData: Data?         // Most degraded for danger
    var generationPrompt: String?      // Stored for regeneration
    var lastGenerated: Date
    var generatedBy: GenerationSource

    enum GenerationSource: String, Codable {
        case mock              // MVP placeholder
        case dalle3            // Azure OpenAI
        case manual            // User uploaded
    }
}
