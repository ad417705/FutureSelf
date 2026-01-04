//  FutureSelfView.swift
import SwiftUI

struct FutureSelfView: View {
    @EnvironmentObject var container: AppContainer
    let goal: Goal

    @State private var budgetStatus: BudgetStatus = .good
    @State private var monthlySpent: Decimal = 0
    @State private var monthlyBudget: Decimal = 0
    @State private var isRegenerating: Bool = false
    @State private var currentGoal: Goal
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    init(goal: Goal) {
        self.goal = goal
        _currentGoal = State(initialValue: goal)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Goal Header
                VStack(spacing: 8) {
                    Text(currentGoal.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(currentGoal.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // FutureSelf Image with Status Effects
                FutureSelfImageView(
                    goal: currentGoal,
                    budgetStatus: budgetStatus
                )

                // Status Message
                StatusMessageCard(status: budgetStatus)

                // Progress Section
                ProgressSection(goal: currentGoal)

                // Actions
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Label("Add to Goal", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        Task {
                            await regenerateVision()
                        }
                    }) {
                        HStack {
                            if isRegenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                            }
                            Label("Refresh Vision", systemImage: "arrow.clockwise")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(isRegenerating)
                }

                // Milestones
                if currentGoal.progress > 0 {
                    MilestonesSection(goal: currentGoal)
                }
            }
            .padding()
        }
        .navigationTitle("Your FutureSelf")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadBudgetStatus()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func loadBudgetStatus() async {
        do {
            let envelopes = try await container.envelopeService.getEnvelopes()
            monthlyBudget = envelopes.reduce(Decimal(0)) { $0 + $1.budgetAmount }
            monthlySpent = envelopes.reduce(Decimal(0)) { $0 + $1.spentAmount }

            let percentUsed = monthlyBudget > 0 ? (monthlySpent / monthlyBudget).asDouble : 0
            if percentUsed >= 1.0 {
                budgetStatus = .danger
            } else if percentUsed >= 0.8 {
                budgetStatus = .warning
            } else {
                budgetStatus = .good
            }
        } catch {
            print("Error loading budget status: \(error)")
        }
    }

    private func regenerateVision() async {
        isRegenerating = true
        defer { isRegenerating = false }

        do {
            // Get user photo from current user
            let userPhoto = container.currentUser.profilePhotoData

            // Generate new vision
            let newVision = try await container.imageGenerationService.generateAllStatusVariations(
                for: currentGoal,
                userPhoto: userPhoto
            )

            // Update goal with new vision
            var updatedGoal = currentGoal
            updatedGoal.futureVision = newVision
            updatedGoal.lastVisualizationUpdate = Date()

            // Save updated goal
            _ = try await container.goalService.updateGoal(updatedGoal)

            // Update UI
            currentGoal = updatedGoal

            // Provide haptic feedback on success
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error regenerating vision: \(error)")
            errorMessage = "We couldn't refresh your vision right now. Please check your connection and try again."
            showErrorAlert = true

            // Provide haptic feedback on error
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

struct FutureSelfImageView: View {
    let goal: Goal
    let budgetStatus: BudgetStatus

    private var displayImageData: Data? {
        guard let vision = goal.futureVision else { return nil }

        switch budgetStatus {
        case .good: return vision.baseImageData
        case .warning: return vision.warningImageData
        case .danger: return vision.dangerImageData
        }
    }

    var body: some View {
        ZStack {
            // AI-Generated Image or Fallback
            if let imageData = displayImageData,
               let uiImage = UIImage(data: imageData) {
                // Display AI-generated image
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(statusBorderColor, lineWidth: budgetStatus == .danger ? 3 : 0)
                    )
                    .animation(.easeInOut(duration: 0.5), value: budgetStatus)
                    .accessibilityLabel("Your FutureSelf vision for \(goal.name)")
                    .accessibilityHint(accessibilityHintText)
            } else {
                // Fallback to icon-based design if no image available
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 250, height: 250)

                    Image(systemName: goal.type.icon)
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                }
                .blur(radius: fallbackBlur)
                .saturation(fallbackSaturation)
                .opacity(fallbackOpacity)
                .animation(.easeInOut(duration: 0.5), value: budgetStatus)
                .accessibilityLabel("\(goal.type.displayName) goal visualization")
                .accessibilityHint(accessibilityHintText)

                // Status overlay effects for fallback
                if budgetStatus == .danger {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 3)
                        .frame(width: 260, height: 260)
                }
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    StatusBadge(status: budgetStatus)
                        .padding()
                }
            }
        )
    }

    private var accessibilityHintText: String {
        switch budgetStatus {
        case .good:
            return "You're staying on budget. Your vision is clear and bright."
        case .warning:
            return "You're approaching your budget limit. Your vision is starting to fade."
        case .danger:
            return "You've exceeded your budget. Your vision is heavily degraded."
        }
    }

    private var statusBorderColor: Color {
        switch budgetStatus {
        case .good: return .clear
        case .warning: return .orange.opacity(0.3)
        case .danger: return .red.opacity(0.5)
        }
    }

    // Fallback blur/saturation for icon-based design
    private var fallbackBlur: CGFloat {
        switch budgetStatus {
        case .good: return 0
        case .warning: return 2
        case .danger: return 5
        }
    }

    private var fallbackSaturation: Double {
        switch budgetStatus {
        case .good: return 1.0
        case .warning: return 0.7
        case .danger: return 0.3
        }
    }

    private var fallbackOpacity: Double {
        switch budgetStatus {
        case .good: return 1.0
        case .warning: return 0.85
        case .danger: return 0.6
        }
    }

    private var gradientColors: [Color] {
        switch budgetStatus {
        case .good: return [.blue, .purple]
        case .warning: return [.orange, .yellow]
        case .danger: return [.red, .pink]
        }
    }
}

struct StatusMessageCard: View {
    let status: BudgetStatus

    var body: some View {
        VStack(spacing: 8) {
            Text(statusMessage)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(status.color.opacity(0.1))
        .cornerRadius(12)
    }

    private var statusMessage: String {
        switch status {
        case .good:
            return "Your future is looking bright! Keep up the great work and you'll reach your goal."
        case .warning:
            return "A few clouds on the horizon. Small adjustments can keep you on track."
        case .danger:
            return "Your vision is getting foggy. Let's focus on the essentials first, then we'll get back to this goal."
        }
    }
}

struct ProgressSection: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)

            if let target = goal.targetAmount {
                ProgressView(value: goal.progress)
                    .tint(.blue)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(goal.currentAmount as NSDecimalNumber, formatter: currencyFormatter)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(target as NSDecimalNumber, formatter: currencyFormatter)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }

                HStack {
                    Text("\(Int(goal.progress * 100))% Complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    let remaining = target - goal.currentAmount
                    Text("\(remaining as NSDecimalNumber, formatter: currencyFormatter) to go")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MilestonesSection: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)

            HStack(spacing: 12) {
                if goal.progress >= 0.25 {
                    MilestoneBadge(title: "25%", icon: "flag.fill", color: .green)
                }
                if goal.progress >= 0.50 {
                    MilestoneBadge(title: "Halfway!", icon: "star.fill", color: .orange)
                }
                if goal.progress >= 0.75 {
                    MilestoneBadge(title: "75%", icon: "flame.fill", color: .red)
                }
                if goal.progress >= 1.0 {
                    MilestoneBadge(title: "Complete!", icon: "crown.fill", color: .yellow)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MilestoneBadge: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatusBadge: View {
    let status: BudgetStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(status.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.2))
        .cornerRadius(12)
    }

    private var statusIcon: String {
        switch status {
        case .good: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.circle.fill"
        }
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.maximumFractionDigits = 0
    return f
}()
