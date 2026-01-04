//  GoalDetailsView.swift
import SwiftUI

struct GoalDetailsView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var targetAmountText: String = ""
    @State private var hasTargetDate: Bool = false
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var customName: String = ""
    @State private var description: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Text("Goal Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Tell us more about your goal")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Custom name for custom goals
                    if coordinator.progress.collectedData.goalType == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name")
                                .font(.headline)
                            TextField("What are you saving for?", text: $customName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)
                        TextField("Add a brief description", text: $description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(2...4)
                    }

                    // Target amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Amount")
                            .font(.headline)
                        HStack {
                            Text("$")
                            TextField("0.00", text: $targetAmountText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    // Target date
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Set Target Date", isOn: $hasTargetDate)
                            .font(.headline)

                        if hasTargetDate {
                            DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                    }
                }
                .padding()
            }

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                Button("Back") {
                    coordinator.goBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Button("Continue") {
                    saveDetails()
                    coordinator.advance()
                }
                .disabled(!isValid)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .padding()
        .onAppear {
            // Load existing data if available
            if let amount = coordinator.progress.collectedData.targetAmount {
                targetAmountText = "\(amount)"
            }
            if let date = coordinator.progress.collectedData.targetDate {
                hasTargetDate = true
                targetDate = date
            }
            customName = coordinator.progress.collectedData.goalName ?? ""
            description = coordinator.progress.collectedData.goalDescription ?? ""
        }
    }

    private var isValid: Bool {
        let hasValidName = coordinator.progress.collectedData.goalType != .custom || !customName.isEmpty
        let hasValidAmount = !targetAmountText.isEmpty && Decimal(string: targetAmountText) != nil
        return hasValidName && hasValidAmount
    }

    private func saveDetails() {
        coordinator.progress.collectedData.targetAmount = Decimal(string: targetAmountText)
        coordinator.progress.collectedData.targetDate = hasTargetDate ? targetDate : nil
        coordinator.progress.collectedData.goalName = coordinator.progress.collectedData.goalType == .custom ? customName : coordinator.progress.collectedData.goalType?.displayName
        coordinator.progress.collectedData.goalDescription = description.isEmpty ? "Working toward my future" : description
    }
}
