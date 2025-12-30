//
//  AIServiceModels.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation

// MARK: - Transaction Parsing Models

public struct ParsedTransaction: Codable {
    public let amount: Double
    public let description: String
    public let date: String
    public let category: String?
    public let confidence: Double
}

public struct CategorySuggestion: Codable {
    public let category: String
    public let confidence: Double
    public let reasoning: String
}

// MARK: - Insights Models

public struct TransactionData: Codable {
    public let amount: Double
    public let description: String
    public let category: String
    public let date: String

    public init(amount: Double, description: String, category: String, date: String) {
        self.amount = amount
        self.description = description
        self.category = category
        self.date = date
    }
}

public struct BudgetData: Codable {
    public let category: String
    public let limit: Double
    public let spent: Double
    public let period: String

    public init(category: String, limit: Double, spent: Double, period: String) {
        self.category = category
        self.limit = limit
        self.spent = spent
        self.period = period
    }
}

public struct InsightData: Codable {
    public let type: String // "pattern", "budget_alert", "progress", "income_spending"
    public let title: String
    public let message: String
    public let priority: String // "low", "medium", "high"
    public let actionable: Bool

    public init(type: String, title: String, message: String, priority: String, actionable: Bool) {
        self.type = type
        self.title = title
        self.message = message
        self.priority = priority
        self.actionable = actionable
    }
}

public struct InsightsResponse: Codable {
    public let insights: [InsightData]

    public init(insights: [InsightData]) {
        self.insights = insights
    }
}

// MARK: - Chat Models

public struct ChatMessageData: Codable {
    public let role: String // "user" or "assistant"
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct FinancialContext: Codable {
    public let totalIncome: Double?
    public let totalSpending: Double
    public let topCategory: String?
    public let budgetStatus: String
    public let recentTransactions: [TransactionData]
    public let uncategorizedTransactions: [TransactionData]
    public let hasVariableIncome: Bool

    public init(totalIncome: Double?, totalSpending: Double, topCategory: String?, budgetStatus: String, recentTransactions: [TransactionData], uncategorizedTransactions: [TransactionData], hasVariableIncome: Bool) {
        self.totalIncome = totalIncome
        self.totalSpending = totalSpending
        self.topCategory = topCategory
        self.budgetStatus = budgetStatus
        self.recentTransactions = recentTransactions
        self.uncategorizedTransactions = uncategorizedTransactions
        self.hasVariableIncome = hasVariableIncome
    }
}

// MARK: - Goals Models

public struct GoalSuggestion: Codable {
    public let name: String
    public let targetAmount: Double
    public let timeframeMonths: Int
    public let priority: String // "high", "medium", "low"
    public let strategy: String
    public let rationale: String

    public init(name: String, targetAmount: Double, timeframeMonths: Int, priority: String, strategy: String, rationale: String) {
        self.name = name
        self.targetAmount = targetAmount
        self.timeframeMonths = timeframeMonths
        self.priority = priority
        self.strategy = strategy
        self.rationale = rationale
    }
}

public struct GoalSuggestionsResponse: Codable {
    public let goals: [GoalSuggestion]

    public init(goals: [GoalSuggestion]) {
        self.goals = goals
    }
}
