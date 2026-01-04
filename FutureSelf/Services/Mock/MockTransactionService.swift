//  MockTransactionService.swift
import Foundation
import Combine

@MainActor
class MockTransactionService: TransactionServiceProtocol {
    private let userId: String
    private let subject = CurrentValueSubject<[Transaction], Never>([])
    var transactionsPublisher: AnyPublisher<[Transaction], Never> { subject.eraseToAnyPublisher() }
    
    init(userId: String) {
        self.userId = userId
        let cal = Calendar.current
        let now = Date()
        subject.send([
            Transaction(userId: userId, amount: 1200, description: "Rent Payment", category: .housing, date: cal.date(byAdding: .day, value: -25, to: now)!),
            Transaction(userId: userId, amount: 67.43, description: "Whole Foods", category: .food, date: cal.date(byAdding: .day, value: -2, to: now)!),
            Transaction(userId: userId, amount: 15.99, description: "Netflix", category: .entertainment, date: cal.date(byAdding: .day, value: -5, to: now)!),
            Transaction(userId: userId, amount: -2500, description: "Direct Deposit", category: .income, date: cal.date(byAdding: .day, value: -14, to: now)!),
            Transaction(userId: userId, amount: 85.20, description: "Electric Bill", category: .utilities, date: cal.date(byAdding: .day, value: -10, to: now)!),
            Transaction(userId: userId, amount: 45.00, description: "Gas", category: .transportation, date: cal.date(byAdding: .day, value: -3, to: now)!),
            Transaction(userId: userId, amount: 32.50, description: "Grocery Store", category: .food, date: cal.date(byAdding: .day, value: -1, to: now)!)
        ])
    }
    
    func getTransactions() async throws -> [Transaction] { subject.value.sorted { $0.date > $1.date } }

    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        var transactions = subject.value
        transactions.append(transaction)
        subject.send(transactions)
        return transaction
    }

    func getSpendingByCategory(from: Date, to: Date) async throws -> [CategorySpending] {
        let txs = subject.value.filter { $0.amount > 0 && $0.date >= from && $0.date <= to }
        let total = txs.reduce(Decimal(0)) { $0 + $1.amount }
        var cats: [TransactionCategory: Decimal] = [:]
        for tx in txs { cats[tx.category, default: 0] += tx.amount }
        return cats.map { CategorySpending(category: $0.key, amount: $0.value, percentage: total > 0 ? ($0.value / total).asDouble : 0) }
    }
}
