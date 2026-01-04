//  AddGoalView.swift
import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var container: AppContainer

    @State private var goalType: GoalType = .emergencyFund
    @State private var customName: String = ""
    @State private var description: String = ""
    @State private var targetAmount: String = ""
    @State private var hasTargetDate: Bool = false
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Type") {
                    Picker("Type", selection: $goalType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                }

                Section("Details") {
                    if goalType == .custom {
                        TextField("Goal Name", text: $customName)
                    }

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Target") {
                    HStack {
                        Text("$")
                        TextField("Target Amount", text: $targetAmount)
                            .keyboardType(.decimalPad)
                    }

                    Toggle("Set Target Date", isOn: $hasTargetDate)

                    if hasTargetDate {
                        DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    }
                }

                Section("Preview") {
                    GoalPreviewCard(
                        name: goalName,
                        description: goalDescription,
                        type: goalType,
                        targetAmount: Decimal(string: targetAmount) ?? 0,
                        currentAmount: 0
                    )
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isValid || isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var goalName: String {
        if goalType == .custom {
            return customName.isEmpty ? "My Goal" : customName
        } else {
            return goalType.displayName
        }
    }

    private var goalDescription: String {
        description.isEmpty ? "Working toward my future" : description
    }

    private var isValid: Bool {
        let hasValidName = goalType != .custom || !customName.isEmpty
        let hasValidAmount = !targetAmount.isEmpty && Decimal(string: targetAmount) != nil
        return hasValidName && hasValidAmount
    }

    private func saveGoal() {
        guard let amount = Decimal(string: targetAmount) else {
            errorMessage = "Invalid target amount"
            showError = true
            return
        }

        isLoading = true

        Task {
            do {
                let goal = Goal(
                    userId: container.currentUser.id,
                    name: goalName,
                    description: goalDescription,
                    type: goalType,
                    targetAmount: amount,
                    currentAmount: 0,
                    targetDate: hasTargetDate ? targetDate : nil,
                    isActive: true
                )

                _ = try await container.goalService.createGoal(goal)
                dismiss()
            } catch {
                errorMessage = "Failed to save goal: \(error.localizedDescription)"
                showError = true
                isLoading = false
            }
        }
    }
}

struct GoalPreviewCard: View {
    let name: String
    let description: String
    let type: GoalType
    let targetAmount: Decimal
    let currentAmount: Decimal

    private var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(1.0, (currentAmount / targetAmount).asDouble)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(name)
                    .font(.headline)
                Spacer()
                Text("Active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: progress)

            HStack {
                Text("\(currentAmount as NSDecimalNumber, formatter: currencyFormatter)")
                    .font(.callout)
                Text("of \(targetAmount as NSDecimalNumber, formatter: currencyFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.maximumFractionDigits = 0
    return f
}()

#Preview {
    AddGoalView()
        .environmentObject(AppContainer.shared)
}
