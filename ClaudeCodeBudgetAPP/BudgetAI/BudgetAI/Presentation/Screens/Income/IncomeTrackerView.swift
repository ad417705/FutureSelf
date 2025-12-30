//
//  IncomeTrackerView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct IncomeTrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: IncomeViewModel
    @State private var selectedPeriod: IncomePeriod = .month
    @State private var showingAddIncome = false
    @State private var showingProfile = false

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: IncomeViewModel(viewContext: viewContext))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(IncomePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .onChange(of: selectedPeriod) { newPeriod in
                        HapticManager.shared.selection()
                        Task {
                            await viewModel.loadIncomeData(period: newPeriod)
                        }
                    }

                    // Variable Income Badge
                    if viewModel.hasVariableIncome {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(Color.blue)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4)
                            Text("Variable Income Detected")
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Spacer()
                            Text("Showing averages")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }

                    // Summary Cards
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Income Card
                        SummaryCard(
                            title: viewModel.hasVariableIncome ? "Avg Monthly Income" : "Total Income",
                            value: viewModel.hasVariableIncome ? viewModel.averageMonthlyIncome : viewModel.totalIncome,
                            icon: "arrow.down.circle.fill",
                            color: DesignSystem.Colors.success
                        )

                        // Expenses Card
                        SummaryCard(
                            title: "Total Expenses",
                            value: viewModel.totalExpenses,
                            icon: "arrow.up.circle.fill",
                            color: DesignSystem.Colors.error
                        )

                        // Net Income Card
                        SummaryCard(
                            title: "Net Income",
                            value: viewModel.netIncome,
                            icon: "equal.circle.fill",
                            color: Color.blue
                        )

                        // Savings Rate Card
                        SavingsRateCard(savingsRate: viewModel.savingsRate)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    // Income vs Expense Chart
                    IncomeExpenseChart(
                        income: viewModel.hasVariableIncome ? viewModel.averageMonthlyIncome : viewModel.totalIncome,
                        expenses: viewModel.totalExpenses
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    // Income Transactions List
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Income Transactions")
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .padding(.horizontal, DesignSystem.Spacing.md)

                        if viewModel.incomeTransactions.isEmpty {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(DesignSystem.Colors.success.opacity(0.6))
                                    .shadow(color: DesignSystem.Colors.success.opacity(0.2), radius: 8)

                                Text("No income recorded")
                                    .font(DesignSystem.Typography.bodyBold)
                                    .foregroundColor(DesignSystem.Colors.primaryText)

                                Text("Add income transactions to track your earnings")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.xxl)
                        } else {
                            ForEach(Array(viewModel.incomeTransactions.enumerated()), id: \.element.id) { index, transaction in
                                IncomeTransactionRow(transaction: transaction)
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                            }
                            .onDelete(perform: deleteIncomeTransactions)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Income Tracker")
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
                    Button(action: { showingAddIncome = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add income")
                    .accessibilityHint("Open form to add new income entry")
                }
            }
            .task {
                await viewModel.loadIncomeData(period: selectedPeriod)
            }
            .onChange(of: showingAddIncome) { isShowing in
                if !isShowing {
                    // Refresh data when sheet dismisses
                    Task {
                        await viewModel.loadIncomeData(period: selectedPeriod)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("IncomeAdded"))) { _ in
                print("🔔 Received IncomeAdded notification - refreshing income data")
                Task {
                    await viewModel.loadIncomeData(period: selectedPeriod)
                }
            }
            .sheet(isPresented: $showingAddIncome) {
                AddIncomeView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSettingsView()
            }
        }
    }

    private func deleteIncomeTransactions(at offsets: IndexSet) {
        withAnimation(DesignSystem.Animations.premium) {
            offsets.map { viewModel.incomeTransactions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                HapticManager.shared.success()

                // Refresh income data
                Task {
                    await viewModel.loadIncomeData(period: selectedPeriod)
                }
            } catch {
                let nsError = error as NSError
                print("Error deleting income transaction: \(nsError), \(nsError.userInfo)")
                HapticManager.shared.error()
            }
        }
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .shadow(color: color.opacity(0.2), radius: 4)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                Text(String(format: "$%.2f", value))
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - Savings Rate Card

struct SavingsRateCard: View {
    let savingsRate: Double

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(savingsRateColor)
                    .shadow(color: savingsRateColor.opacity(0.3), radius: 4)
                Text("Savings Rate")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            HStack(alignment: .bottom, spacing: DesignSystem.Spacing.sm) {
                Text(String(format: "%.1f%%", savingsRate))
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(savingsRateColor)

                Text(savingsRateMessage)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(DesignSystem.Colors.elevatedBackground)
                        .frame(height: 8)
                        .cornerRadius(DesignSystem.CornerRadius.small)

                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [savingsRateColor, savingsRateColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(geometry.size.width * CGFloat(savingsRate / 100), geometry.size.width), height: 8)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        .shadow(color: savingsRateColor.opacity(0.3), radius: 4)
                }
            }
            .frame(height: 8)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }

    private var savingsRateColor: Color {
        if savingsRate < 0 {
            return DesignSystem.Colors.error  // Red for overspending
        } else if savingsRate < 10 {
            return DesignSystem.Colors.warning  // Orange for getting started
        } else if savingsRate < 20 {
            return Color.yellow  // Yellow for good progress
        } else {
            return DesignSystem.Colors.success  // Green for excellent
        }
    }

    private var savingsRateMessage: String {
        if savingsRate < 0 {
            return "Overspending"
        } else if savingsRate < 10 {
            return "Getting started"
        } else if savingsRate < 20 {
            return "Good progress"
        } else {
            return "Excellent!"
        }
    }
}

// MARK: - Income vs Expense Chart

struct IncomeExpenseChart: View {
    let income: Double
    let expenses: Double

    private var total: Double {
        income + expenses
    }

    private var incomePercentage: Double {
        guard total > 0 else { return 0 }
        return income / total
    }

    private var expensePercentage: Double {
        guard total > 0 else { return 0 }
        return expenses / total
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Income vs Expenses")
                .font(DesignSystem.Typography.bodyBold)
                .foregroundColor(DesignSystem.Colors.primaryText)

            // Single proportional bar chart
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Income portion (green)
                    if income > 0 {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(incomePercentage))
                    }

                    // Expense portion (red)
                    if expenses > 0 {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.error.opacity(0.8), DesignSystem.Colors.error],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(expensePercentage))
                    }
                }
                .frame(height: 40)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .shadow(color: .black.opacity(0.2), radius: 4)
            }
            .frame(height: 40)

            // Legend
            HStack(spacing: DesignSystem.Spacing.lg) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Circle()
                        .fill(DesignSystem.Colors.success)
                        .frame(width: 12, height: 12)
                        .shadow(color: DesignSystem.Colors.success.opacity(0.3), radius: 2)
                    Text("Income: $\(String(format: "%.2f", income))")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Circle()
                        .fill(DesignSystem.Colors.error)
                        .frame(width: 12, height: 12)
                        .shadow(color: DesignSystem.Colors.error.opacity(0.3), radius: 2)
                    Text("Expenses: $\(String(format: "%.2f", expenses))")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - Income Transaction Row

struct IncomeTransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(transaction.transactionDescription ?? "Income")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(transaction.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            Spacer()

            Text((transaction.amount as Decimal?)?.toCurrencyString() ?? "$0.00")
                .font(DesignSystem.Typography.bodyBold)
                .foregroundColor(DesignSystem.Colors.success)
                .shadow(color: DesignSystem.Colors.success.opacity(0.2), radius: 4)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

// MARK: - Add Income View

struct AddIncomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Income Details") {
                    TextField("Description (e.g., Salary, Freelance)", text: $description)

                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Add Income")
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
                        saveIncome()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                    .foregroundColor(
                        (amount.isEmpty || description.isEmpty) ?
                            DesignSystem.Colors.tertiaryText :
                            DesignSystem.Colors.luxuryGold
                    )
                }
            }
        }
    }

    private func saveIncome() {
        print("🔵 saveIncome called - Amount: '\(amount)', Description: '\(description)'")

        guard let amountValue = Double(amount) else {
            print("❌ Failed to convert amount '\(amount)' to Double")
            return
        }

        print("🔵 Creating transaction with amount: $\(amountValue)")

        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(value: amountValue)
        transaction.transactionDescription = description
        transaction.category = "Income"
        transaction.date = date
        transaction.createdAt = Date()
        transaction.updatedAt = Date()
        transaction.isAIProcessed = false

        do {
            try viewContext.save()
            print("✅ Income saved successfully: \(description) - $\(amountValue)")

            // Haptic feedback for success
            HapticManager.shared.success()

            // Post notification to refresh other views if needed
            NotificationCenter.default.post(name: NSNotification.Name("IncomeAdded"), object: nil)

            dismiss()
        } catch {
            print("❌ Error saving income: \(error.localizedDescription)")
            HapticManager.shared.error()
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return IncomeTrackerView(viewContext: context)
}
