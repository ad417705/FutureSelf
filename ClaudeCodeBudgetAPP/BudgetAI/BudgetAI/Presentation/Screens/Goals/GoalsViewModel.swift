//
//  GoalsViewModel.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import CoreData
import Combine

@MainActor
class GoalsViewModel: ObservableObject {
    @Published var goals: [SavingsGoal] = []
    @Published var aiSuggestions: [GoalSuggestion] = []
    @Published var isLoadingSuggestions: Bool = false
    @Published var errorMessage: String?

    private let aiService: AIServiceProtocol
    private let viewContext: NSManagedObjectContext

    init(aiService: AIServiceProtocol, viewContext: NSManagedObjectContext) {
        self.aiService = aiService
        self.viewContext = viewContext
    }

    // MARK: - Load Goals

    func loadGoals() {
        let fetchRequest: NSFetchRequest<SavingsGoal> = SavingsGoal.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavingsGoal.priority, ascending: true),
            NSSortDescriptor(keyPath: \SavingsGoal.deadline, ascending: true)
        ]

        do {
            goals = try viewContext.fetch(fetchRequest)
        } catch {
            print("❌ Error loading goals: \(error.localizedDescription)")
            errorMessage = "Failed to load goals"
        }
    }

    // MARK: - Get AI Goal Suggestions

    func getAISuggestions() async {
        isLoadingSuggestions = true
        errorMessage = nil

        do {
            // Fetch recent transactions to calculate income and spending
            let calendar = Calendar.current
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!

            let transactionFetch: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            transactionFetch.predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)

            let transactions = try viewContext.fetch(transactionFetch)

            // Calculate income, spending, and category breakdown
            var income: Double? = nil
            var spending: Double = 0
            var categoryBreakdown: [String: Double] = [:]

            for transaction in transactions {
                let amount = (transaction.amount as Decimal?)?.doubleValue ?? 0
                let category = transaction.category ?? "Uncategorized"

                if category == "Income" {
                    if income == nil {
                        income = 0
                    }
                    income! += amount
                } else if category != "Uncategorized" {
                    spending += amount
                    categoryBreakdown[category, default: 0] += amount
                }
            }

            // Get AI suggestions
            let suggestions = try await aiService.suggestSavingsGoals(
                income: income,
                spending: spending,
                categoryBreakdown: categoryBreakdown
            )

            aiSuggestions = suggestions
            isLoadingSuggestions = false

        } catch {
            print("❌ Error getting AI goal suggestions: \(error.localizedDescription)")
            errorMessage = "Failed to get AI suggestions"
            isLoadingSuggestions = false
        }
    }

    // MARK: - Create Goal from Suggestion

    func createGoalFromSuggestion(_ suggestion: GoalSuggestion) {
        let goal = SavingsGoal(context: viewContext)
        goal.id = UUID()
        goal.name = suggestion.name
        goal.targetAmount = NSDecimalNumber(value: suggestion.targetAmount)
        goal.currentAmount = NSDecimalNumber(value: 0)

        // Calculate deadline based on timeframe
        let calendar = Calendar.current
        goal.deadline = calendar.date(byAdding: .month, value: suggestion.timeframeMonths, to: Date())

        goal.priority = priorityValue(suggestion.priority)
        goal.isAISuggested = true
        goal.aiStrategy = suggestion.strategy
        goal.createdAt = Date()
        goal.updatedAt = Date()

        do {
            try viewContext.save()
            print("✅ Goal created from AI suggestion: \(suggestion.name)")
            loadGoals()

            // Remove this suggestion from the list
            aiSuggestions.removeAll { $0.name == suggestion.name }

        } catch {
            print("❌ Error creating goal: \(error.localizedDescription)")
            errorMessage = "Failed to create goal"
        }
    }

    // MARK: - Create Custom Goal

    func createCustomGoal(name: String, targetAmount: Double, deadline: Date, priority: Int16) {
        let goal = SavingsGoal(context: viewContext)
        goal.id = UUID()
        goal.name = name
        goal.targetAmount = NSDecimalNumber(value: targetAmount)
        goal.currentAmount = NSDecimalNumber(value: 0)
        goal.deadline = deadline
        goal.priority = priority
        goal.isAISuggested = false
        goal.createdAt = Date()
        goal.updatedAt = Date()

        do {
            try viewContext.save()
            print("✅ Custom goal created: \(name)")
            loadGoals()
        } catch {
            print("❌ Error creating custom goal: \(error.localizedDescription)")
            errorMessage = "Failed to create goal"
        }
    }

    // MARK: - Update Goal Progress

    func updateGoalProgress(goal: SavingsGoal, newAmount: Double) {
        goal.currentAmount = NSDecimalNumber(value: newAmount)
        goal.updatedAt = Date()

        // Calculate predicted completion date if making progress
        if newAmount > 0 {
            let progress = newAmount / ((goal.targetAmount as Decimal?)?.doubleValue ?? 1)
            if progress > 0 && progress < 1 {
                let daysSinceCreation = Calendar.current.dateComponents([.day], from: goal.createdAt ?? Date(), to: Date()).day ?? 1
                let estimatedTotalDays = Int(Double(daysSinceCreation) / progress)
                goal.predictedCompletionDate = Calendar.current.date(byAdding: .day, value: estimatedTotalDays - daysSinceCreation, to: Date())
            }
        }

        do {
            try viewContext.save()
            print("✅ Goal progress updated: \(goal.name ?? "Unknown") - $\(newAmount)")
            loadGoals()
        } catch {
            print("❌ Error updating goal progress: \(error.localizedDescription)")
            errorMessage = "Failed to update progress"
        }
    }

    // MARK: - Delete Goal

    func deleteGoal(_ goal: SavingsGoal) {
        viewContext.delete(goal)

        do {
            try viewContext.save()
            print("✅ Goal deleted: \(goal.name ?? "Unknown")")
            loadGoals()
        } catch {
            print("❌ Error deleting goal: \(error.localizedDescription)")
            errorMessage = "Failed to delete goal"
        }
    }

    // MARK: - Helpers

    private func priorityValue(_ priority: String) -> Int16 {
        switch priority.lowercased() {
        case "high": return 1
        case "medium": return 2
        case "low": return 3
        default: return 2
        }
    }
}
