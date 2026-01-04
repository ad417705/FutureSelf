//  Goal.swift
import Foundation

struct Goal: Identifiable, Codable {
    let id: String
    let userId: String
    var name: String
    var description: String
    var type: GoalType
    var targetAmount: Decimal?
    var currentAmount: Decimal
    var targetDate: Date?
    var isActive: Bool
    var detailedWhy: String?                 // User's detailed goal explanation
    var goalDetails: GoalDetails?            // Structured details for AI prompts
    var futureVision: FutureVision?          // All visualization data
    var lastVisualizationUpdate: Date?       // Track regeneration timing

    init(id: String = UUID().uuidString, userId: String, name: String, description: String, type: GoalType = .custom, targetAmount: Decimal? = nil, currentAmount: Decimal = 0, targetDate: Date? = nil, isActive: Bool = true, detailedWhy: String? = nil, goalDetails: GoalDetails? = nil, futureVision: FutureVision? = nil, lastVisualizationUpdate: Date? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.type = type
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.isActive = isActive
        self.detailedWhy = detailedWhy
        self.goalDetails = goalDetails
        self.futureVision = futureVision
        self.lastVisualizationUpdate = lastVisualizationUpdate
    }

    var progress: Double {
        guard let target = targetAmount, target > 0 else { return 0 }
        return min(1.0, Double(truncating: (currentAmount / target) as NSNumber))
    }
}

enum GoalType: String, Codable, CaseIterable {
    case emergencyFund = "Build emergency cushion"
    case debtFree = "Get out of debt"
    case moveOut = "Move to my own place"
    case travel = "Take a trip"
    case education = "Invest in education"
    case familySupport = "Support my family"
    case retirement = "Start retirement savings"
    case custom = "Custom goal"

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .emergencyFund: return "shield.fill"
        case .debtFree: return "creditcard.fill"
        case .moveOut: return "house.fill"
        case .travel: return "airplane"
        case .education: return "graduationcap.fill"
        case .familySupport: return "heart.circle.fill"
        case .retirement: return "calendar.badge.clock"
        case .custom: return "star.fill"
        }
    }
}
