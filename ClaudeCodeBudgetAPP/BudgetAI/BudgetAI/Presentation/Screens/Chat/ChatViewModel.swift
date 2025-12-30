//
//  ChatViewModel.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import CoreData
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatDisplayMessage] = []
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?

    private let aiService: AIServiceProtocol
    private let viewContext: NSManagedObjectContext
    private let conversationId: UUID

    init(aiService: AIServiceProtocol, viewContext: NSManagedObjectContext) {
        self.aiService = aiService
        self.viewContext = viewContext
        self.conversationId = UUID()
    }

    // MARK: - Load Messages

    func loadMessages() {
        let fetchRequest: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChatMessage.timestamp, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationId as CVarArg)

        do {
            let chatMessages = try viewContext.fetch(fetchRequest)
            messages = chatMessages.map { msg in
                ChatDisplayMessage(
                    id: msg.id ?? UUID(),
                    content: msg.content ?? "",
                    isUser: msg.role == "user",
                    timestamp: msg.timestamp ?? Date()
                )
            }
        } catch {
            print("❌ Error loading messages: \(error.localizedDescription)")
        }
    }

    // MARK: - Send Message

    func sendMessage(_ text: String) async {
        // Check if this is a transaction creation request
        let lowercaseText = text.lowercased()
        let isTransactionRequest = lowercaseText.contains("spent") ||
                                   lowercaseText.contains("paid") ||
                                   lowercaseText.contains("bought") ||
                                   lowercaseText.contains("cost") ||
                                   lowercaseText.contains("$") ||
                                   (lowercaseText.contains("add") && lowercaseText.contains("transaction"))

        // Check if this is a categorization request
        let isCategorizationRequest = lowercaseText.contains("categorize") ||
                                      lowercaseText.contains("category") ||
                                      lowercaseText.contains("organize")

        // Add user message to UI (only if not an internal request)
        if !lowercaseText.contains("categorize next transaction") {
            let userMessage = ChatDisplayMessage(
                id: UUID(),
                content: text,
                isUser: true,
                timestamp: Date()
            )
            messages.append(userMessage)

            // Save user message to Core Data
            saveMessage(content: text, role: "user")
        }

        // Start processing
        isProcessing = true
        errorMessage = nil

        do {
            // Handle transaction creation request
            if isTransactionRequest && !isCategorizationRequest {
                do {
                    // Parse the transaction using AI
                    let parsed = try await aiService.parseNaturalLanguageTransaction(text)

                    // Create transaction in Core Data
                    let transaction = Transaction(context: viewContext)
                    transaction.id = UUID()
                    transaction.amount = NSDecimalNumber(value: parsed.amount)
                    transaction.transactionDescription = parsed.description
                    transaction.category = parsed.category ?? "Uncategorized"
                    transaction.date = ISO8601DateFormatter().date(from: parsed.date) ?? Date()
                    transaction.rawInput = text
                    transaction.createdAt = Date()
                    transaction.updatedAt = Date()
                    transaction.isAIProcessed = true
                    transaction.categoryConfidence = Float(parsed.confidence)
                    transaction.needsSync = false

                    try viewContext.save()

                    // Add confirmation message
                    let confirmationMessage = ChatDisplayMessage(
                        id: UUID(),
                        content: "✓ Added transaction: \(parsed.description) - $\(String(format: "%.2f", parsed.amount))\nCategory: \(parsed.category ?? "Uncategorized")",
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(confirmationMessage)

                    // Save confirmation message
                    saveMessage(content: confirmationMessage.content, role: "assistant")

                    isProcessing = false
                    return
                } catch {
                    print("❌ Error creating transaction: \(error.localizedDescription)")
                    // Fall through to normal chat if parsing fails
                }
            }

            // Build financial context
            let context = try buildFinancialContext()

            // If this is a categorization request and there are uncategorized transactions
            if isCategorizationRequest && !context.uncategorizedTransactions.isEmpty {
                // Get the first uncategorized transaction
                let transaction = try getFirstUncategorizedTransaction()

                // Get AI category suggestion
                let suggestion = try await aiService.categorizeTransaction(
                    description: transaction.transactionDescription ?? "",
                    amount: (transaction.amount as Decimal?) ?? 0
                )

                // Add category suggestion message with action buttons
                await addCategorySuggestion(
                    transactionId: transaction.id ?? UUID(),
                    description: transaction.transactionDescription ?? "Unknown",
                    amount: (transaction.amount as Decimal?)?.doubleValue ?? 0,
                    category: suggestion.category,
                    confidence: suggestion.confidence
                )

                isProcessing = false
                return
            }

            // Normal chat flow
            // Prepare messages for AI
            let chatMessages = messages.map { msg in
                ChatMessageData(role: msg.isUser ? "user" : "assistant", content: msg.content)
            }

            // Get AI response
            let response = try await aiService.chat(messages: chatMessages, financialContext: context)

            // Add assistant message to UI
            let assistantMessage = ChatDisplayMessage(
                id: UUID(),
                content: response,
                isUser: false,
                timestamp: Date()
            )
            messages.append(assistantMessage)

            // Save assistant message to Core Data
            saveMessage(content: response, role: "assistant")

            isProcessing = false

        } catch {
            print("❌ Chat error: \(error.localizedDescription)")
            errorMessage = "Failed to get response from FutureSelf"
            isProcessing = false

            // Add error message to UI
            let errorMsg = ChatDisplayMessage(
                id: UUID(),
                content: "Sorry, I'm having trouble responding right now. Please try again.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorMsg)
        }
    }

    // MARK: - Build Financial Context

    private func buildFinancialContext() throws -> FinancialContext {
        // Fetch recent transactions (last 30 days)
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!

        let transactionFetch: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        transactionFetch.predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)
        transactionFetch.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        transactionFetch.fetchLimit = 50

        let transactions = try viewContext.fetch(transactionFetch)

        // Calculate totals
        var totalSpending: Double = 0
        var totalIncome: Double? = nil
        var categoryTotals: [String: Double] = [:]

        for transaction in transactions {
            let amount = (transaction.amount as Decimal?)?.doubleValue ?? 0
            let category = transaction.category ?? "Uncategorized"

            if category == "Income" {
                if totalIncome == nil {
                    totalIncome = 0
                }
                totalIncome! += amount
            } else {
                totalSpending += amount
                categoryTotals[category, default: 0] += amount
            }
        }

        // Find top category
        let topCategory = categoryTotals.max(by: { $0.value < $1.value })?.key

        // Determine budget status
        let budgetStatus: String
        if totalIncome != nil && totalIncome! > 0 {
            let savingsRate = ((totalIncome! - totalSpending) / totalIncome!) * 100
            if savingsRate > 20 {
                budgetStatus = "Saving well"
            } else if savingsRate > 0 {
                budgetStatus = "On track"
            } else {
                budgetStatus = "Overspending"
            }
        } else {
            budgetStatus = "Unknown"
        }

        // Build recent transactions array
        let recentTransactions = transactions.prefix(10).map { tx in
            TransactionData(
                amount: (tx.amount as Decimal?)?.doubleValue ?? 0,
                description: tx.transactionDescription ?? "Unknown",
                category: tx.category ?? "Uncategorized",
                date: ISO8601DateFormatter().string(from: tx.date ?? Date())
            )
        }

        // Build uncategorized transactions array
        let uncategorizedTransactions = transactions
            .filter { $0.category == "Uncategorized" }
            .map { tx in
                TransactionData(
                    amount: (tx.amount as Decimal?)?.doubleValue ?? 0,
                    description: tx.transactionDescription ?? "Unknown",
                    category: "Uncategorized",
                    date: ISO8601DateFormatter().string(from: tx.date ?? Date())
                )
            }

        return FinancialContext(
            totalIncome: totalIncome,
            totalSpending: totalSpending,
            topCategory: topCategory,
            budgetStatus: budgetStatus,
            recentTransactions: Array(recentTransactions),
            uncategorizedTransactions: Array(uncategorizedTransactions),
            hasVariableIncome: false // TODO: Implement based on UserPreferences
        )
    }

    // MARK: - Save Message

    private func saveMessage(content: String, role: String) {
        let message = ChatMessage(context: viewContext)
        message.id = UUID()
        message.content = content
        message.role = role
        message.timestamp = Date()
        message.conversationId = conversationId

        do {
            try viewContext.save()
        } catch {
            print("❌ Error saving message: \(error.localizedDescription)")
        }
    }

    // MARK: - Category Suggestion Management

    func removeCategorySuggestion(messageId: UUID) async {
        messages.removeAll { $0.id == messageId }
    }

    func addConfirmationMessage(category: String?, transactionDescription: String?) async {
        let content: String
        if let category = category, let description = transactionDescription {
            content = "✓ Applied \(category) to \(description)"
        } else {
            content = "Skipped"
        }

        let confirmationMessage = ChatDisplayMessage(
            id: UUID(),
            content: content,
            isUser: false,
            timestamp: Date()
        )
        messages.append(confirmationMessage)
    }

    // MARK: - Category Suggestion Helper

    func addCategorySuggestion(transactionId: UUID, description: String, amount: Double, category: String, confidence: Double) async {
        let message = ChatDisplayMessage(
            id: UUID(),
            content: "I suggest categorizing '\(description)' ($\(String(format: "%.2f", amount))) as:",
            isUser: false,
            timestamp: Date(),
            suggestedCategory: category,
            categoryConfidence: confidence,
            transactionId: transactionId
        )
        messages.append(message)
    }

    private func getFirstUncategorizedTransaction() throws -> Transaction {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", "Uncategorized")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        fetchRequest.fetchLimit = 1

        let transactions = try viewContext.fetch(fetchRequest)
        guard let transaction = transactions.first else {
            throw NSError(domain: "ChatViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "No uncategorized transactions found"])
        }

        return transaction
    }
}

// MARK: - Decimal Extension

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
