//  GoalDetailView.swift
import SwiftUI

struct GoalDetailView: View {
    @EnvironmentObject var container: AppContainer
    let goal: Goal

    @State private var showingAddFunds = false
    @State private var amountToAdd: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Goal Icon & Title
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: goal.type.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                    }

                    Text(goal.name)
                        .font(.title)
                        .fontWeight(.bold)

                    if goal.isActive {
                        Text("Active Goal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Description
                Text(goal.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Progress
                if let target = goal.targetAmount {
                    VStack(spacing: 16) {
                        // Circular Progress
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 200, height: 200)

                            Circle()
                                .trim(from: 0, to: goal.progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: goal.progress)

                            VStack(spacing: 4) {
                                Text("\(Int(goal.progress * 100))%")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Amount Details
                        HStack(spacing: 32) {
                            VStack(spacing: 4) {
                                Text("Saved")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(goal.currentAmount as NSDecimalNumber, formatter: currencyFormatter)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }

                            Divider()
                                .frame(height: 40)

                            VStack(spacing: 4) {
                                Text("Remaining")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\((target - goal.currentAmount) as NSDecimalNumber, formatter: currencyFormatter)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }

                // Target Date
                if let targetDate = goal.targetDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Target Date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(targetDate, style: .date)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        if targetDate > Date() {
                            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
                            Text("\(daysLeft) days left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // Add Funds Button
                Button(action: { showingAddFunds = true }) {
                    Label("Add Funds", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }

                // Quick Add Amounts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        QuickAddButton(amount: 10)
                        QuickAddButton(amount: 25)
                        QuickAddButton(amount: 50)
                        QuickAddButton(amount: 100)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddFunds) {
            AddFundsView(goal: goal)
        }
    }
}

struct QuickAddButton: View {
    let amount: Int

    var body: some View {
        Button(action: {}) {
            Text("+$\(amount)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct AddFundsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var container: AppContainer
    let goal: Goal

    @State private var amount: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }

                Section {
                    Button("Add to Goal") {
                        addFunds()
                    }
                    .disabled(amount.isEmpty || Decimal(string: amount) == nil)
                }
            }
            .navigationTitle("Add Funds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addFunds() {
        guard let amountDecimal = Decimal(string: amount) else { return }

        Task {
            do {
                var updatedGoal = goal
                updatedGoal.currentAmount += amountDecimal
                _ = try await container.goalService.updateGoal(updatedGoal)
                dismiss()
            } catch {
                print("Error updating goal: \(error)")
            }
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
