//  TransactionsViewModel.swift
import Foundation
import Combine

@MainActor
class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    private let transactionService: TransactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(transactionService: TransactionServiceProtocol) {
        self.transactionService = transactionService
        transactionService.transactionsPublisher.receive(on: DispatchQueue.main).assign(to: &$transactions)
    }
    
    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        do { transactions = try await transactionService.getTransactions() } catch { print("Error: \(error)") }
    }
}
