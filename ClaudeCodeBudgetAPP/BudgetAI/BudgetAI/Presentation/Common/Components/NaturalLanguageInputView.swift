//
//  NaturalLanguageInputView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct NaturalLanguageInputView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var input: String = ""
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccess: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundColor(DesignSystem.Colors.luxuryGold)
                    .font(.title3)
                    .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 6)

                Text("Quick Add with AI")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            HStack(spacing: DesignSystem.Spacing.md) {
                TextField("Try: 'I spent $20 on coffee'", text: $input)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.elevatedBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .disabled(isProcessing)
                    .onSubmit {
                        Task {
                            await processInput()
                        }
                    }

                Button(action: {
                    HapticManager.shared.lightImpact()
                    Task {
                        await processInput()
                    }
                }) {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(DesignSystem.Colors.luxuryGold)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(input.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.luxuryGold)
                            .shadow(color: input.isEmpty ? .clear : DesignSystem.Colors.luxuryGold.opacity(0.5), radius: 10)
                    }
                }
                .disabled(input.isEmpty || isProcessing)
            }

            if let error = errorMessage {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(DesignSystem.Typography.caption)
                    Text(error)
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(DesignSystem.Colors.error)
            }

            if showSuccess {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.success)
                    Text("Transaction added!")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .stroke(DesignSystem.Colors.luxuryGold.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.1), radius: 8, y: 4)
    }

    private func processInput() async {
        guard !input.isEmpty else { return }

        isProcessing = true
        errorMessage = nil
        showSuccess = false

        do {
            // Load Azure config
            guard let config = AzureConfig.load() else {
                errorMessage = "AI service not configured"
                isProcessing = false
                return
            }

            // Create AI service
            let aiService = AzureOpenAIService(config: config)

            // Parse transaction
            let parsed = try await aiService.parseNaturalLanguageTransaction(input)

            // Create transaction in Core Data
            await MainActor.run {
                let transaction = Transaction(context: viewContext)
                transaction.id = UUID()
                transaction.amount = NSDecimalNumber(value: parsed.amount)
                transaction.transactionDescription = parsed.description
                transaction.category = parsed.category ?? "Uncategorized"
                transaction.date = ISO8601DateFormatter().date(from: parsed.date) ?? Date()
                transaction.rawInput = input
                transaction.createdAt = Date()
                transaction.updatedAt = Date()
                transaction.isAIProcessed = true
                transaction.categoryConfidence = Float(parsed.confidence)
                transaction.needsSync = false

                do {
                    try viewContext.save()
                    input = ""
                    showSuccess = true

                    // Haptic feedback for success
                    HapticManager.shared.success()

                    // Hide success message after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccess = false
                    }
                } catch {
                    errorMessage = "Failed to save transaction"
                    HapticManager.shared.error()
                }

                isProcessing = false
            }

        } catch {
            await MainActor.run {
                errorMessage = "AI parsing failed. Try manual entry."
                isProcessing = false
            }
        }
    }
}

#Preview {
    NaturalLanguageInputView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .padding()
}
