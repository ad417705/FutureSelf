//
//  TransactionRepository.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation
import CoreData

class TransactionRepository: TransactionRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAllTransactions() -> [Transaction] {
        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching transactions: \(error)")
            return []
        }
    }

    func fetchTransactions(for dateRange: ClosedRange<Date>) -> [Transaction] {
        let request = Transaction.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            dateRange.lowerBound as NSDate,
            dateRange.upperBound as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching transactions for date range: \(error)")
            return []
        }
    }

    func fetchTransactions(for category: String) -> [Transaction] {
        let request = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching transactions for category: \(error)")
            return []
        }
    }

    func createTransaction(amount: Decimal, description: String, category: String, date: Date) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = amount as NSDecimalNumber
        transaction.transactionDescription = description
        transaction.category = category
        transaction.date = date
        transaction.createdAt = Date()
        transaction.updatedAt = Date()
        transaction.isAIProcessed = false
        transaction.needsSync = false
        transaction.categoryConfidence = 0.0
        transaction.isRecurring = false

        save()
        return transaction
    }

    func updateTransaction(_ transaction: Transaction) {
        transaction.updatedAt = Date()
        save()
    }

    func deleteTransaction(_ transaction: Transaction) {
        context.delete(transaction)
        save()
    }

    func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
}
