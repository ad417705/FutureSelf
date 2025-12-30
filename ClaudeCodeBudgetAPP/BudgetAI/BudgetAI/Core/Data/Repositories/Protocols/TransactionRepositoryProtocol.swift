//
//  TransactionRepositoryProtocol.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import CoreData

protocol TransactionRepositoryProtocol {
    func fetchAllTransactions() -> [Transaction]
    func fetchTransactions(for dateRange: ClosedRange<Date>) -> [Transaction]
    func fetchTransactions(for category: String) -> [Transaction]
    func createTransaction(amount: Decimal, description: String, category: String, date: Date) -> Transaction
    func updateTransaction(_ transaction: Transaction)
    func deleteTransaction(_ transaction: Transaction)
    func save()
}
