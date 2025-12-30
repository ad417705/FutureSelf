//
//  IncomeViewModel.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import CoreData
import Combine

@MainActor
class IncomeViewModel: ObservableObject {
    @Published var totalIncome: Double = 0
    @Published var averageMonthlyIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var netIncome: Double = 0
    @Published var savingsRate: Double = 0
    @Published var incomeTransactions: [Transaction] = []
    @Published var hasVariableIncome: Bool = false

    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    // MARK: - Load Income Data

    func loadIncomeData(period: IncomePeriod = .month) async {
        let calendar = Calendar.current
        let now = Date()

        // Calculate date range based on period
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now)!
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }

        // Fetch all transactions in period
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            let transactions = try viewContext.fetch(fetchRequest)

            // Separate income and expenses
            var income: Double = 0
            var expenses: Double = 0
            var incomeList: [Transaction] = []

            for transaction in transactions {
                let amount = (transaction.amount as Decimal?)?.doubleValue ?? 0
                let category = transaction.category ?? "Uncategorized"

                if category == "Income" {
                    income += amount
                    incomeList.append(transaction)
                } else if category != "Uncategorized" {
                    expenses += amount
                }
            }

            // Calculate metrics
            totalIncome = income
            totalExpenses = expenses
            netIncome = income - expenses
            incomeTransactions = incomeList

            // Calculate savings rate
            if income > 0 {
                savingsRate = ((income - expenses) / income) * 100
            } else {
                savingsRate = 0
            }

            // Calculate average monthly income
            let monthsInPeriod = period.monthsCount
            if monthsInPeriod > 0 {
                averageMonthlyIncome = income / Double(monthsInPeriod)
            } else {
                averageMonthlyIncome = income
            }

            // Detect variable income (if income varies significantly month-to-month)
            await detectVariableIncome()

        } catch {
            print("❌ Error loading income data: \(error.localizedDescription)")
        }
    }

    // MARK: - Variable Income Detection

    private func detectVariableIncome() async {
        // Fetch last 3 months of income to check variance
        let calendar = Calendar.current
        let now = Date()
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND category == %@", threeMonthsAgo as NSDate, "Income")

        do {
            let incomeTransactions = try viewContext.fetch(fetchRequest)

            // Group by month
            var monthlyIncome: [Int: Double] = [:]

            for transaction in incomeTransactions {
                guard let date = transaction.date else { continue }
                let month = calendar.component(.month, from: date)
                let amount = (transaction.amount as Decimal?)?.doubleValue ?? 0
                monthlyIncome[month, default: 0] += amount
            }

            // If we have at least 2 months of data
            if monthlyIncome.count >= 2 {
                let incomeValues = Array(monthlyIncome.values)
                let average = incomeValues.reduce(0, +) / Double(incomeValues.count)

                // Calculate standard deviation
                let variance = incomeValues.reduce(0) { sum, value in
                    sum + pow(value - average, 2)
                } / Double(incomeValues.count)

                let standardDeviation = sqrt(variance)

                // If standard deviation is more than 20% of average, consider it variable
                let coefficientOfVariation = (standardDeviation / average) * 100
                hasVariableIncome = coefficientOfVariation > 20
            } else {
                hasVariableIncome = false
            }

        } catch {
            print("❌ Error detecting variable income: \(error.localizedDescription)")
            hasVariableIncome = false
        }
    }
}

// MARK: - Income Period

enum IncomePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case year = "Year"

    var monthsCount: Int {
        switch self {
        case .week: return 0
        case .month: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .year: return 12
        }
    }
}
