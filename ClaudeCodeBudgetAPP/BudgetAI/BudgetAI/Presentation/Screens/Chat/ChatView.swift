//
//  ChatView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct ChatView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText: String = ""
    @State private var showingAIAssistant = false
    @State private var showingProfile = false
    @FocusState private var isInputFocused: Bool

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        predicate: NSPredicate(format: "category == %@", "Uncategorized"),
        animation: .default)
    private var uncategorizedTransactions: FetchedResults<Transaction>

    init(viewContext: NSManagedObjectContext) {
        let config = AzureConfig.load()!
        let aiService = AzureOpenAIService(config: config)
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            aiService: aiService,
            viewContext: viewContext
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Welcome message
                        if viewModel.messages.isEmpty {
                            VStack(spacing: DesignSystem.Spacing.lg) {
                                Image(systemName: "sparkles.rectangle.stack.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(DesignSystem.Colors.luxuryGold)
                                    .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 20)

                                Text("Hi! I'm FutureSelf")
                                    .font(DesignSystem.Typography.title1)
                                    .foregroundColor(DesignSystem.Colors.primaryText)

                                Text("I'm here to help you build better financial habits. Ask me anything about your spending, saving, or budgeting!")
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, DesignSystem.Spacing.lg)
                            }
                            .padding(.top, DesignSystem.Spacing.xxl)
                        }

                        // Chat messages
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            MessageBubble(
                                message: message,
                                onApplyCategory: { transactionId, category in
                                    applyCategory(transactionId: transactionId, category: category, messageId: message.id)
                                },
                                onSkipCategory: { transactionId in
                                    skipCategory(transactionId: transactionId, messageId: message.id)
                                }
                            )
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }

                        // Typing indicator
                        if viewModel.isProcessing {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    // Auto-scroll to bottom when new message arrives
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(DesignSystem.Animations.smooth) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input area
            HStack(spacing: DesignSystem.Spacing.md) {
                TextField("Ask FutureSelf anything...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.cardBackground)
                    .cornerRadius(DesignSystem.CornerRadius.large)
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                    .onSubmit {
                        sendMessage()
                    }
                    .accessibilityLabel("Message")
                    .accessibilityHint("Type your message to FutureSelf AI assistant")

                Button(action: {
                    HapticManager.shared.lightImpact()
                    sendMessage()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(messageText.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.luxuryGold)
                        .shadow(color: messageText.isEmpty ? .clear : DesignSystem.Colors.luxuryGold.opacity(0.5), radius: 12)
                }
                .disabled(messageText.isEmpty || viewModel.isProcessing)
                .accessibilityLabel("Send message")
                .accessibilityHint(messageText.isEmpty ? "Type a message first" : "Send message to FutureSelf")
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primaryBackground)
        }
        .background(DesignSystem.Colors.primaryBackground.ignoresSafeArea())
        .navigationTitle("FutureSelf")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingProfile = true }) {
                    Image(systemName: "person.circle")
                        .font(.title3)
                }
                .accessibilityLabel("Profile")
                .accessibilityHint("Open profile and settings")
            }
        }
        .onAppear {
            viewModel.loadMessages()
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView(transactions: Array(uncategorizedTransactions))
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileSettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TransactionCategorized"))) { _ in
            print("🔔 FutureSelf received TransactionCategorized notification")
            viewContext.refreshAllObjects()
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let text = messageText
        messageText = ""
        isInputFocused = false

        Task {
            await viewModel.sendMessage(text)
        }
    }

    private func applyCategory(transactionId: UUID, category: String, messageId: UUID) {
        // Find the transaction
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", transactionId as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            let transactions = try viewContext.fetch(fetchRequest)
            guard let transaction = transactions.first else {
                print("❌ Transaction not found: \(transactionId)")
                return
            }

            // Apply category
            transaction.category = category
            transaction.isAIProcessed = true
            transaction.updatedAt = Date()

            // Save
            try viewContext.save()

            print("✅ Category '\(category)' applied to transaction: \(transaction.transactionDescription ?? "Unknown")")

            // Post notification to refresh TransactionListView
            NotificationCenter.default.post(name: NSNotification.Name("TransactionCategorized"), object: nil)

            // Haptic feedback for success
            HapticManager.shared.success()

            // Remove the message with action buttons and add confirmation
            Task {
                await viewModel.removeCategorySuggestion(messageId: messageId)
                await viewModel.addConfirmationMessage(category: category, transactionDescription: transaction.transactionDescription ?? "transaction")

                // Check if there are more uncategorized transactions
                let uncategorizedCount = uncategorizedTransactions.count
                if uncategorizedCount > 0 {
                    // Ask FutureSelf to suggest the next one
                    await viewModel.sendMessage("categorize next transaction")
                }
            }

        } catch {
            print("❌ Error applying category: \(error.localizedDescription)")
        }
    }

    private func skipCategory(transactionId: UUID, messageId: UUID) {
        // Remove the message with action buttons
        Task {
            await viewModel.removeCategorySuggestion(messageId: messageId)
            await viewModel.addConfirmationMessage(category: nil, transactionDescription: nil)

            // Check if there are more uncategorized transactions
            let uncategorizedCount = uncategorizedTransactions.count
            if uncategorizedCount > 0 {
                // Ask FutureSelf to suggest the next one
                await viewModel.sendMessage("categorize next transaction")
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatDisplayMessage
    var onApplyCategory: ((UUID, String) -> Void)? = nil
    var onSkipCategory: ((UUID) -> Void)? = nil

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: DesignSystem.Spacing.sm) {
                // Message content
                Text(message.content)
                    .font(DesignSystem.Typography.callout)
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        Group {
                            if message.isUser {
                                DesignSystem.Colors.accentGradient
                            } else {
                                LinearGradient(
                                    colors: [DesignSystem.Colors.cardBackground],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .foregroundColor(message.isUser ? Color(hex: "#1a1a1a") : DesignSystem.Colors.primaryText)
                    .cornerRadius(DesignSystem.CornerRadius.large)
                    .shadow(
                        color: message.isUser ? DesignSystem.Colors.luxuryGold.opacity(0.3) : .black.opacity(0.1),
                        radius: 8,
                        y: 4
                    )

                // Category suggestion buttons
                if message.hasCategorySuggestion,
                   let category = message.suggestedCategory,
                   let transactionId = message.transactionId,
                   let confidence = message.categoryConfidence {

                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Category badge
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Text(category)
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(DesignSystem.Colors.luxuryGold.opacity(0.15))
                                .foregroundColor(DesignSystem.Colors.luxuryGold)
                                .cornerRadius(DesignSystem.CornerRadius.small)

                            Text("\(Int(confidence * 100))%")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }

                        // Action buttons
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Button(action: {
                                HapticManager.shared.mediumImpact()
                                onApplyCategory?(transactionId, category)
                            }) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Apply")
                                }
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(DesignSystem.Colors.accentGradient)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.4), radius: 10, y: 4)
                            }

                            Button(action: {
                                HapticManager.shared.lightImpact()
                                onSkipCategory?(transactionId)
                            }) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "arrow.right.circle")
                                    Text("Skip")
                                }
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(DesignSystem.Colors.elevatedBackground)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                }

                // Timestamp
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase: Int = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .padding(12)
        .background(Color(.systemGray5))
        .cornerRadius(16)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: false)) {
                animationPhase = 0
            }
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

// MARK: - Display Model

struct ChatDisplayMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date

    // Optional category suggestion data
    let suggestedCategory: String?
    let categoryConfidence: Double?
    let transactionId: UUID?

    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date(), suggestedCategory: String? = nil, categoryConfidence: Double? = nil, transactionId: UUID? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.suggestedCategory = suggestedCategory
        self.categoryConfidence = categoryConfidence
        self.transactionId = transactionId
    }

    var hasCategorySuggestion: Bool {
        suggestedCategory != nil && transactionId != nil
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ChatView(viewContext: PersistenceController.preview.container.viewContext)
    }
}
