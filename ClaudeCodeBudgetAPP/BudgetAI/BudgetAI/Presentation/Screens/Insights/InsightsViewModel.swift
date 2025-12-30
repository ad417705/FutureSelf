//
//  InsightsViewModel.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import CoreData
import Combine

@MainActor
class InsightsViewModel: ObservableObject {
    @Published var insights: [InsightData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let aiService: AIServiceProtocol
    private let viewContext: NSManagedObjectContext

    init(aiService: AIServiceProtocol, viewContext: NSManagedObjectContext) {
        self.aiService = aiService
        self.viewContext = viewContext
    }

    // MARK: - Load Insights

    func loadInsights() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch transactions (last 30 days)
            let calendar = Calendar.current
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!

            let transactionFetch: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            transactionFetch.predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)
            transactionFetch.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

            let transactions = try viewContext.fetch(transactionFetch)

            // Build transaction data for AI
            let transactionData = transactions.map { tx in
                TransactionData(
                    amount: (tx.amount as Decimal?)?.doubleValue ?? 0,
                    description: tx.transactionDescription ?? "Unknown",
                    category: tx.category ?? "Uncategorized",
                    date: ISO8601DateFormatter().string(from: tx.date ?? Date())
                )
            }

            // Fetch budgets
            let budgetFetch: NSFetchRequest<Budget> = Budget.fetchRequest()
            let budgets = try viewContext.fetch(budgetFetch)

            // Calculate spending by category for budget data
            var categorySpending: [String: Double] = [:]
            for transaction in transactions {
                let category = transaction.category ?? "Uncategorized"
                let amount = (transaction.amount as Decimal?)?.doubleValue ?? 0

                // Skip income
                if category == "Income" {
                    continue
                }

                categorySpending[category, default: 0] += amount
            }

            // Build budget data for AI
            let budgetData = budgets.map { budget in
                let category = budget.category ?? "Unknown"
                let limit = (budget.limit as Decimal?)?.doubleValue ?? 0
                let spent = categorySpending[category] ?? 0

                return BudgetData(
                    category: category,
                    limit: limit,
                    spent: spent,
                    period: "monthly" // TODO: Support different periods
                )
            }

            // Generate insights with AI
            if !transactionData.isEmpty {
                let generatedInsights = try await aiService.generateInsights(
                    transactions: transactionData,
                    budgets: budgetData
                )

                // Sort insights by priority (high -> medium -> low)
                let sortedInsights = generatedInsights.sorted { insight1, insight2 in
                    let priority1 = priorityValue(insight1.priority)
                    let priority2 = priorityValue(insight2.priority)
                    return priority1 > priority2
                }

                insights = sortedInsights
            } else {
                insights = []
            }

            isLoading = false

        } catch {
            print("❌ Error loading insights: \(error.localizedDescription)")
            errorMessage = "Failed to generate insights"
            isLoading = false
        }
    }

    // MARK: - Helpers

    private func priorityValue(_ priority: String) -> Int {
        switch priority.lowercased() {
        case "high": return 3
        case "medium": return 2
        case "low": return 1
        default: return 0
        }
    }
}
