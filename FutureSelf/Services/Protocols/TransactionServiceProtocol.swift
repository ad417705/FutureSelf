//  TransactionServiceProtocol.swift
import Foundation
import Combine

protocol TransactionServiceProtocol {
    var transactionsPublisher: AnyPublisher<[Transaction], Never> { get }
    func getTransactions() async throws -> [Transaction]
    func createTransaction(_ transaction: Transaction) async throws -> Transaction
    func getSpendingByCategory(from: Date, to: Date) async throws -> [CategorySpending]
}
