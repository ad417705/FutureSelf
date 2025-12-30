//
//  AIAssistantView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct AIAssistantView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    let transactions: [Transaction]
    @State private var currentIndex = 0
    @State private var isProcessing = false
    @State private var suggestedCategory: String?
    @State private var confidence: Double = 0
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private var currentTransaction: Transaction? {
        guard currentIndex < transactions.count else { return nil }
        return transactions[currentIndex]
    }

    private var hasMore: Bool {
        currentIndex < transactions.count - 1
    }

    var body: some View {
        NavigationView {
            ZStack {
                if let transaction = currentTransaction {
                    VStack(spacing: 24) {
                        // Progress indicator
                        HStack {
                            Text("Transaction \(currentIndex + 1) of \(transactions.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()
                        }
                        .padding(.horizontal)

                        // AI Assistant Header
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)

                            Text("AI Categorization Assistant")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Let me help you categorize this transaction")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)

                        // Transaction Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.transactionDescription ?? "Unknown")
                                        .font(.title3)
                                        .fontWeight(.semibold)

                                    Text(transaction.date?.formatted(date: .long, time: .omitted) ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text((transaction.amount as Decimal?)?.toCurrencyString() ?? "$0.00")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }

                            Divider()

                            // AI Suggestion
                            if isProcessing {
                                HStack {
                                    ProgressView()
                                    Text("Analyzing with AI...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            } else if let category = suggestedCategory {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("AI Suggestion:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    HStack {
                                        Text(category)
                                            .font(.headline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)

                                        Text("\(Int(confidence * 100))% confident")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        Spacer()

                        // Action Buttons
                        VStack(spacing: 12) {
                            if suggestedCategory != nil && !isProcessing {
                                Button(action: applyCategory) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Apply Category")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }

                                Button(action: skipTransaction) {
                                    HStack {
                                        Image(systemName: "arrow.right.circle")
                                        Text(hasMore ? "Skip This One" : "Done")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                }
                            } else if !isProcessing {
                                Button(action: {
                                    Task {
                                        await getCategorySuggestion()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text("Get AI Suggestion")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                } else {
                    // All done!
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)

                        Text("All Categorized!")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Great job organizing your transactions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: { dismiss() }) {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            // Auto-load AI suggestion for first transaction
            if currentTransaction != nil && suggestedCategory == nil {
                await getCategorySuggestion()
            }
        }
    }

    private func getCategorySuggestion() async {
        guard let transaction = currentTransaction else { return }

        isProcessing = true
        errorMessage = nil

        do {
            guard let config = AzureConfig.load() else {
                errorMessage = "AI service not configured"
                isProcessing = false
                return
            }

            let aiService = AzureOpenAIService(config: config)
            let amount = (transaction.amount as Decimal?) ?? 0

            let suggestion = try await aiService.categorizeTransaction(
                description: transaction.transactionDescription ?? "",
                amount: amount
            )

            await MainActor.run {
                suggestedCategory = suggestion.category
                confidence = suggestion.confidence
                isProcessing = false
            }

        } catch {
            await MainActor.run {
                errorMessage = "Failed to get AI suggestion"
                isProcessing = false
            }
        }
    }

    private func applyCategory() {
        guard let transaction = currentTransaction,
              let category = suggestedCategory else { return }

        // Update transaction properties on main thread
        transaction.category = category
        transaction.categoryConfidence = Float(confidence)
        transaction.isAIProcessed = true
        transaction.updatedAt = Date()

        do {
            // Process pending changes
            viewContext.processPendingChanges()

            // Save changes
            try viewContext.save()

            // Debug logging
            print("✅ Category '\(category)' applied to transaction: \(transaction.transactionDescription ?? "Unknown")")
            print("   ID: \(transaction.id?.uuidString ?? "no-id")")
            print("   Category saved: \(transaction.category ?? "nil")")
            print("   isAIProcessed: \(transaction.isAIProcessed)")

            // Force refresh the object to ensure it's in sync
            viewContext.refresh(transaction, mergeChanges: true)

            // Post notification to refresh transaction list
            NotificationCenter.default.post(name: NSNotification.Name("TransactionCategorized"), object: nil)

            moveToNext()
        } catch {
            print("❌ Error saving category: \(error.localizedDescription)")
            errorMessage = "Failed to save category"
        }
    }

    private func skipTransaction() {
        moveToNext()
    }

    private func moveToNext() {
        if hasMore {
            currentIndex += 1
            suggestedCategory = nil
            confidence = 0
            errorMessage = nil

            // Auto-load next suggestion
            Task {
                await getCategorySuggestion()
            }
        } else {
            dismiss()
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    // Create sample uncategorized transaction
    let transaction = Transaction(context: context)
    transaction.id = UUID()
    transaction.amount = 25.50
    transaction.transactionDescription = "Starbucks Coffee"
    transaction.category = "Uncategorized"
    transaction.date = Date()
    transaction.createdAt = Date()
    transaction.updatedAt = Date()

    return AIAssistantView(transactions: [transaction])
        .environment(\.managedObjectContext, context)
}
