//
//  GoalsView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct GoalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GoalsViewModel
    @State private var showingAddGoal = false
    @State private var showingProfile = false

    init(viewContext: NSManagedObjectContext) {
        let config = AzureConfig.load()!
        let aiService = AzureOpenAIService(config: config)
        _viewModel = StateObject(wrappedValue: GoalsViewModel(
            aiService: aiService,
            viewContext: viewContext
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // AI Suggestions Section
                    if !viewModel.aiSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(DesignSystem.Colors.luxuryGold)
                                    .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 6)
                                Text("AI Suggested Goals")
                                    .font(DesignSystem.Typography.bodyBold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Spacer()
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    ForEach(Array(viewModel.aiSuggestions.enumerated()), id: \.element.name) { index, suggestion in
                                        AISuggestionCard(suggestion: suggestion) {
                                            HapticManager.shared.success()
                                            viewModel.createGoalFromSuggestion(suggestion)
                                        }
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                                            removal: .scale(scale: 0.8).combined(with: .opacity)
                                        ))
                                    }
                                }
                                .padding(.horizontal, DesignSystem.Spacing.md)
                            }
                        }
                    } else if viewModel.goals.isEmpty && !viewModel.isLoadingSuggestions {
                        // Get AI Suggestions Button
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            Task {
                                await viewModel.getAISuggestions()
                            }
                        }) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "sparkles")
                                Text("Get AI Goal Suggestions")
                            }
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.accentGradient)
                            .cornerRadius(DesignSystem.CornerRadius.large)
                            .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.4), radius: 10, y: 4)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }

                    // Loading State
                    if viewModel.isLoadingSuggestions {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ProgressView()
                                .tint(DesignSystem.Colors.luxuryGold)
                            Text("Analyzing your finances...")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xxl)
                    }

                    // Active Goals Section
                    if !viewModel.goals.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Text("Your Goals")
                                    .font(DesignSystem.Typography.bodyBold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Spacer()
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)

                            ForEach(Array(viewModel.goals.enumerated()), id: \.element.id) { index, goal in
                                GoalCard(goal: goal, viewModel: viewModel)
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                            }
                        }
                    } else if !viewModel.isLoadingSuggestions && viewModel.aiSuggestions.isEmpty {
                        // Empty State
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Image(systemName: "target")
                                .font(.system(size: 60))
                                .foregroundColor(DesignSystem.Colors.luxuryGold.opacity(0.6))
                                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.2), radius: 10)

                            Text("No Goals Yet")
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primaryText)

                            Text("Create a savings goal or get AI suggestions based on your spending!")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DesignSystem.Spacing.lg)

                            Button(action: {
                                HapticManager.shared.mediumImpact()
                                Task {
                                    await viewModel.getAISuggestions()
                                }
                            }) {
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    Image(systemName: "sparkles")
                                    Text("Get AI Suggestions")
                                }
                                .font(DesignSystem.Typography.bodyBold)
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                                .padding(.vertical, DesignSystem.Spacing.md)
                                .background(DesignSystem.Colors.accentGradient)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.4), radius: 8, y: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xxl)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("Profile")
                    .accessibilityHint("Open profile and settings")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add goal")
                    .accessibilityHint("Create a new savings goal")
                }
            }
            .task {
                viewModel.loadGoals()
                if viewModel.goals.isEmpty && viewModel.aiSuggestions.isEmpty {
                    await viewModel.getAISuggestions()
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSettingsView()
            }
        }
    }
}

// MARK: - AI Suggestion Card

struct AISuggestionCard: View {
    let suggestion: GoalSuggestion
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(suggestion.name)
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(2)

                    Text("\(suggestion.timeframeMonths) months")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()

                // Priority badge
                Text(suggestion.priority.capitalized)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(priorityColor.opacity(0.15))
                    .foregroundColor(priorityColor)
                    .cornerRadius(DesignSystem.CornerRadius.small)
            }

            Divider()
                .background(DesignSystem.Colors.elevatedBackground)

            // Target Amount
            Text("$\(String(format: "%.0f", suggestion.targetAmount))")
                .font(DesignSystem.Typography.title1)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.luxuryGold)
                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.2), radius: 4)

            // Strategy
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Strategy:")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                Text(suggestion.strategy)
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .lineLimit(3)
            }

            // Add Button
            Button(action: onAdd) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Goal")
                }
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.accentGradient)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 6, y: 3)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 280)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
    }

    private var priorityColor: Color {
        switch suggestion.priority.lowercased() {
        case "high": return DesignSystem.Colors.error
        case "medium": return DesignSystem.Colors.warning
        case "low": return DesignSystem.Colors.luxuryGold
        default: return DesignSystem.Colors.secondaryText
        }
    }
}

// MARK: - Goal Card

struct GoalCard: View {
    let goal: SavingsGoal
    @ObservedObject var viewModel: GoalsViewModel
    @State private var showingProgressUpdate = false

    private var progress: Double {
        let current = (goal.currentAmount as Decimal?)?.doubleValue ?? 0
        let target = (goal.targetAmount as Decimal?)?.doubleValue ?? 1
        return min(current / target, 1.0)
    }

    private var daysRemaining: Int? {
        guard let deadline = goal.deadline else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(goal.name ?? "Unnamed Goal")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    if let deadline = goal.deadline {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "calendar")
                                .font(DesignSystem.Typography.caption)
                            Text(deadline.formatted(date: .abbreviated, time: .omitted))
                                .font(DesignSystem.Typography.caption)

                            if let days = daysRemaining {
                                Text("• \(days) days left")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(days < 30 ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                            }
                        }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }

                Spacer()

                if goal.isAISuggested {
                    Image(systemName: "sparkles")
                        .foregroundColor(DesignSystem.Colors.luxuryGold)
                        .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 4)
                }
            }

            // Progress
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text("$\(String(format: "%.0f", (goal.currentAmount as Decimal?)?.doubleValue ?? 0))")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    Text("/ $\(String(format: "%.0f", (goal.targetAmount as Decimal?)?.doubleValue ?? 0))")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(progressColor)
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(DesignSystem.Colors.elevatedBackground)
                            .frame(height: 12)
                            .cornerRadius(DesignSystem.CornerRadius.small)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [progressColor, progressColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                            .shadow(color: progressColor.opacity(0.3), radius: 4)
                    }
                }
                .frame(height: 12)
            }

            // AI Strategy (if available)
            if let strategy = goal.aiStrategy {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("AI Strategy:")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Text(strategy)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
                .padding(.top, DesignSystem.Spacing.xs)
            }

            // Action Buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    showingProgressUpdate = true
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "plus.circle")
                        Text("Update Progress")
                    }
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.accentGradient)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 6, y: 3)
                }

                Button(action: {
                    HapticManager.shared.mediumImpact()
                    viewModel.deleteGoal(goal)
                }) {
                    Image(systemName: "trash")
                        .font(DesignSystem.Typography.subheadline)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.error.opacity(0.15))
                        .foregroundColor(DesignSystem.Colors.error)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
        .sheet(isPresented: $showingProgressUpdate) {
            UpdateProgressView(goal: goal, viewModel: viewModel)
        }
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return DesignSystem.Colors.success
        } else if progress >= 0.75 {
            return DesignSystem.Colors.luxuryGold
        } else if progress >= 0.5 {
            return DesignSystem.Colors.champagneGold
        } else {
            return DesignSystem.Colors.warning
        }
    }
}

// MARK: - Add Goal View

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GoalsViewModel

    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
    @State private var selectedPriority: GoalPriority = .medium

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name (e.g., Emergency Fund)", text: $name)

                    TextField("Target Amount", text: $targetAmount)
                        .keyboardType(.decimalPad)

                    DatePicker("Deadline", selection: $deadline, in: Date()..., displayedComponents: .date)
                }

                Section("Priority") {
                    Picker("Priority Level", selection: $selectedPriority) {
                        ForEach(GoalPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(selectedPriority.description)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        HapticManager.shared.mediumImpact()
                        createGoal()
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                    .foregroundColor(
                        (name.isEmpty || targetAmount.isEmpty) ?
                            DesignSystem.Colors.tertiaryText :
                            DesignSystem.Colors.luxuryGold
                    )
                }
            }
        }
    }

    private func createGoal() {
        guard let amount = Double(targetAmount) else { return }
        viewModel.createCustomGoal(name: name, targetAmount: amount, deadline: deadline, priority: selectedPriority.rawValue)
        dismiss()
    }
}

// MARK: - Goal Priority Enum

enum GoalPriority: Int16, CaseIterable {
    case high = 1
    case medium = 2
    case low = 3

    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    var color: Color {
        switch self {
        case .high: return DesignSystem.Colors.error
        case .medium: return DesignSystem.Colors.warning
        case .low: return DesignSystem.Colors.luxuryGold
        }
    }

    var description: String {
        switch self {
        case .high: return "Focus on this goal first - it's a top priority"
        case .medium: return "Important goal to work towards steadily"
        case .low: return "Nice to have - work on when you have extra funds"
        }
    }
}

// MARK: - Update Progress View

struct UpdateProgressView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: SavingsGoal
    @ObservedObject var viewModel: GoalsViewModel

    @State private var newAmount: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Current Progress") {
                    HStack {
                        Text("Current Amount:")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Spacer()
                        Text("$\(String(format: "%.2f", (goal.currentAmount as Decimal?)?.doubleValue ?? 0))")
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(DesignSystem.Colors.luxuryGold)
                    }
                }

                Section("Update Amount") {
                    TextField("New Amount", text: $newAmount)
                        .keyboardType(.decimalPad)

                    Text("Enter the total amount saved so far")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        HapticManager.shared.mediumImpact()
                        updateProgress()
                    }
                    .disabled(newAmount.isEmpty)
                    .foregroundColor(
                        newAmount.isEmpty ?
                            DesignSystem.Colors.tertiaryText :
                            DesignSystem.Colors.luxuryGold
                    )
                }
            }
        }
    }

    private func updateProgress() {
        guard let amount = Double(newAmount) else {
            HapticManager.shared.error()
            return
        }
        viewModel.updateGoalProgress(goal: goal, newAmount: amount)
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return GoalsView(viewContext: context)
}
