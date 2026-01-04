//  DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel: DashboardViewModel
    @State private var isLoaded = false

    init() {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            envelopeService: AppContainer.shared.envelopeService,
            transactionService: AppContainer.shared.transactionService,
            goalService: AppContainer.shared.goalService,
            streakService: AppContainer.shared.streakService
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Monthly Summary
                    MonthlySummaryCard(
                        spent: viewModel.monthlySpent,
                        budget: viewModel.monthlyBudget
                    )
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : 20)

                    // FutureSelf Score
                    FutureSelfScoreCard(score: viewModel.futureselfScore, activeGoal: viewModel.activeGoal)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : 20)

                    // Stability Bar (Essentials)
                    StabilityBarView(
                        housingProgress: viewModel.housingProgress,
                        utilitiesProgress: viewModel.utilitiesProgress,
                        foodProgress: viewModel.foodProgress
                    )
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : 20)

                    // Days Safe Meter
                    DaysSafeMeterView(daysCovered: viewModel.daysSafe)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : 20)

                    // Crisis Streak
                    if let streak = viewModel.currentStreak {
                        CrisisStreakView(
                            currentStreak: streak.currentCount,
                            longestStreak: streak.longestCount
                        )
                        .opacity(isLoaded ? 1 : 0)
                        .offset(y: isLoaded ? 0 : 20)
                    }

                    // Bill Boss
                    if !viewModel.essentialsEnvelopes.isEmpty {
                        BillBossView(envelopes: viewModel.essentialsEnvelopes)
                            .opacity(isLoaded ? 1 : 0)
                            .offset(y: isLoaded ? 0 : 20)
                    }

                    // Spending by Category
                    if !viewModel.spendingByCategory.isEmpty {
                        SpendingCategoryChart(categories: viewModel.spendingByCategory)
                            .opacity(isLoaded ? 1 : 0)
                            .offset(y: isLoaded ? 0 : 20)
                    }

                    // Recent Transactions
                    if !viewModel.recentTransactions.isEmpty {
                        RecentTransactionsSection(transactions: viewModel.recentTransactions)
                            .opacity(isLoaded ? 1 : 0)
                            .offset(y: isLoaded ? 0 : 20)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
                withAnimation(.easeOut(duration: 0.6)) {
                    isLoaded = true
                }
            }
        }
    }
}

struct RecentTransactionsSection: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)

            ForEach(transactions) { transaction in
                HStack {
                    Image(systemName: transaction.category.icon)
                        .foregroundColor(.accentColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.description)
                            .font(.subheadline)
                        Text(transaction.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(transaction.amount as NSDecimalNumber, formatter: currencyFormatter)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(transaction.amount > 0 ? .red : .green)
                }
                .padding(.vertical, 4)

                if transaction.id != transactions.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
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
