//
//  AddTransactionViewModel.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class AddTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var description: String = ""
    @Published var selectedCategory: String = "Uncategorized"
    @Published var selectedDate: Date = Date()
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    private let repository: TransactionRepositoryProtocol

    // Standard budget categories
    let categories = [
        "Groceries",
        "Dining Out",
        "Transportation",
        "Entertainment",
        "Shopping",
        "Health & Fitness",
        "Utilities",
        "Subscriptions",
        "Bills",
        "Income",
        "Other",
        "Uncategorized"
    ]

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    var isValid: Bool {
        !amount.isEmpty && !description.isEmpty && amount.toDecimal() != nil
    }

    func saveTransaction() -> Bool {
        guard isValid else {
            errorMessage = "Please enter a valid amount and description"
            showError = true
            return false
        }

        guard let decimalAmount = amount.toDecimal() else {
            errorMessage = "Invalid amount format"
            showError = true
            return false
        }

        _ = repository.createTransaction(
            amount: decimalAmount,
            description: description,
            category: selectedCategory,
            date: selectedDate
        )

        // Clear form
        amount = ""
        self.description = ""
        selectedCategory = "Uncategorized"
        selectedDate = Date()

        return true
    }
}
