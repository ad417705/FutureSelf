//  DashboardViewModel.swift
import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var monthlySpent: Decimal = 0
    @Published var monthlyBudget: Decimal = 0
    @Published var futureselfScore: Int = 0
    @Published var goals: [Goal] = []
    @Published var recentTransactions: [Transaction] = []
    @Published var spendingByCategory: [CategorySpending] = []
    @Published var envelopes: [Envelope] = []
    @Published var streaks: [Streak] = []
    @Published var daysSafe: Int = 0

    var activeGoal: Goal? {
        goals.first(where: { $0.isActive })
    }

    private let envelopeService: EnvelopeServiceProtocol
    private let transactionService: TransactionServiceProtocol
    private let goalService: GoalServiceProtocol
    private let streakService: StreakServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(envelopeService: EnvelopeServiceProtocol, transactionService: TransactionServiceProtocol, goalService: GoalServiceProtocol, streakService: StreakServiceProtocol) {
        self.envelopeService = envelopeService
        self.transactionService = transactionService
        self.goalService = goalService
        self.streakService = streakService
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load all data
            envelopes = try await envelopeService.getEnvelopes()
            let transactions = try await transactionService.getTransactions()
            goals = try await goalService.getGoals()
            streaks = try await streakService.getStreaks()

            // Calculate monthly totals
            monthlyBudget = envelopes.reduce(Decimal(0)) { $0 + $1.budgetAmount }
            monthlySpent = envelopes.reduce(Decimal(0)) { $0 + $1.spentAmount }

            // Get recent transactions (last 5)
            recentTransactions = Array(transactions.prefix(5))

            // Calculate spending by category
            let monthStart = Date().startOfMonth
            let monthEnd = Date().endOfMonth
            spendingByCategory = try await transactionService.getSpendingByCategory(from: monthStart, to: monthEnd)

            // Calculate FutureSelf Score
            futureselfScore = calculateFutureSelfScore()

            // Calculate days safe
            if let emergencyGoal = goals.first(where: { $0.name.contains("Emergency") }) {
                daysSafe = Int((emergencyGoal.currentAmount / 15).asDouble) // $15 per day estimate
            }

        } catch {
            print("Error loading dashboard data: \(error)")
        }
    }

    func refresh() async {
        await loadData()
    }

    private func calculateFutureSelfScore() -> Int {
        var score = 0

        // Budget adherence (40 points)
        if monthlyBudget > 0 {
            let budgetRatio = (monthlySpent / monthlyBudget).asDouble
            if budgetRatio <= 1.0 {
                score += Int(40 * (1 - budgetRatio))
            }
        }

        // Goal progress (30 points)
        let avgProgress = goals.isEmpty ? 0 : goals.map { $0.progress }.reduce(0, +) / Double(goals.count)
        score += Int(30 * avgProgress)

        // Emergency fund (30 points)
        let daysSafeRatio = min(1.0, Double(daysSafe) / 30.0)
        score += Int(30 * daysSafeRatio)

        return min(100, max(0, score))
    }

    var essentialsEnvelopes: [Envelope] {
        envelopes.filter { $0.isEssential }
    }

    var housingProgress: Double {
        essentialsEnvelopes.first { $0.name.contains("Housing") }?.percentUsed ?? 0
    }

    var utilitiesProgress: Double {
        essentialsEnvelopes.first { $0.name.contains("Utilities") }?.percentUsed ?? 0
    }

    var foodProgress: Double {
        essentialsEnvelopes.first { $0.name.contains("Food") }?.percentUsed ?? 0
    }

    var currentStreak: Streak? {
        streaks.first
    }
}
