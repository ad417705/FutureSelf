//
//  BudgetAITests.swift
//  BudgetAITests
//
//  Created by Marcus Knighton on 12/25/25.
//

import Testing
import CoreData
@testable import BudgetAI

struct BudgetAITests {

    // MARK: - Test Helpers

    /// Creates an in-memory Core Data stack for testing
    func createTestContext() -> NSManagedObjectContext {
        let persistentContainer = NSPersistentContainer(name: "BudgetAI")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        return persistentContainer.viewContext
    }

    // MARK: - Transaction Tests

    @Test func testTransactionCreation() throws {
        let context = createTestContext()

        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(value: 50.00)
        transaction.transactionDescription = "Coffee"
        transaction.category = "Dining Out"
        transaction.date = Date()
        transaction.createdAt = Date()
        transaction.updatedAt = Date()
        transaction.isAIProcessed = false
        transaction.categoryConfidence = 0.0
        transaction.needsSync = false

        try context.save()

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 1)
        #expect(results.first?.transactionDescription == "Coffee")
        #expect((results.first?.amount as Decimal?)?.doubleValue == 50.00)
        #expect(results.first?.category == "Dining Out")
    }

    @Test func testTransactionCategoryFilter() throws {
        let context = createTestContext()

        // Create multiple transactions with different categories
        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.amount = NSDecimalNumber(value: 50.00)
        transaction1.transactionDescription = "Coffee"
        transaction1.category = "Dining Out"
        transaction1.date = Date()
        transaction1.createdAt = Date()
        transaction1.updatedAt = Date()

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.amount = NSDecimalNumber(value: 100.00)
        transaction2.transactionDescription = "Groceries"
        transaction2.category = "Groceries"
        transaction2.date = Date()
        transaction2.createdAt = Date()
        transaction2.updatedAt = Date()

        let transaction3 = Transaction(context: context)
        transaction3.id = UUID()
        transaction3.amount = NSDecimalNumber(value: 25.00)
        transaction3.transactionDescription = "Lunch"
        transaction3.category = "Dining Out"
        transaction3.date = Date()
        transaction3.createdAt = Date()
        transaction3.updatedAt = Date()

        try context.save()

        // Test filtering by category
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", "Dining Out")
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.category == "Dining Out" })
    }

    @Test func testUncategorizedTransactions() throws {
        let context = createTestContext()

        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.amount = NSDecimalNumber(value: 50.00)
        transaction1.transactionDescription = "Unknown Purchase"
        transaction1.category = "Uncategorized"
        transaction1.date = Date()
        transaction1.createdAt = Date()
        transaction1.updatedAt = Date()

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.amount = NSDecimalNumber(value: 100.00)
        transaction2.transactionDescription = "Groceries"
        transaction2.category = "Groceries"
        transaction2.date = Date()
        transaction2.createdAt = Date()
        transaction2.updatedAt = Date()

        try context.save()

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", "Uncategorized")
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 1)
        #expect(results.first?.category == "Uncategorized")
    }

    // MARK: - Income Entry Tests

    @Test func testIncomeEntryCreation() throws {
        let context = createTestContext()

        let income = IncomeEntry(context: context)
        income.id = UUID()
        income.amount = NSDecimalNumber(value: 5000.00)
        income.source = "Salary"
        income.date = Date()
        income.isRecurring = true
        income.isVariable = false
        income.createdAt = Date()

        try context.save()

        let fetchRequest: NSFetchRequest<IncomeEntry> = IncomeEntry.fetchRequest()
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 1)
        #expect(results.first?.source == "Salary")
        #expect((results.first?.amount as Decimal?)?.doubleValue == 5000.00)
        #expect(results.first?.isRecurring == true)
    }

    @Test func testVariableIncomeTracking() throws {
        let context = createTestContext()

        let income1 = IncomeEntry(context: context)
        income1.id = UUID()
        income1.amount = NSDecimalNumber(value: 3000.00)
        income1.source = "Freelance"
        income1.date = Date()
        income1.isVariable = true
        income1.expectedAmount = NSDecimalNumber(value: 3500.00)
        income1.createdAt = Date()

        let income2 = IncomeEntry(context: context)
        income2.id = UUID()
        income2.amount = NSDecimalNumber(value: 4000.00)
        income2.source = "Freelance"
        income2.date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        income2.isVariable = true
        income2.expectedAmount = NSDecimalNumber(value: 3500.00)
        income2.createdAt = Date()

        try context.save()

        let fetchRequest: NSFetchRequest<IncomeEntry> = IncomeEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isVariable == YES")
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 2)

        // Calculate average for variable income
        let total = results.reduce(0.0) { sum, entry in
            sum + ((entry.amount as Decimal?)?.doubleValue ?? 0)
        }
        let average = total / Double(results.count)

        #expect(average == 3500.00)
    }

    // MARK: - Budget Tests

    @Test func testBudgetCreation() throws {
        let context = createTestContext()

        let budget = Budget(context: context)
        budget.id = UUID()
        budget.name = "Groceries Budget"
        budget.category = "Groceries"
        budget.limit = NSDecimalNumber(value: 500.00)
        budget.period = "monthly"
        budget.startDate = Date()
        budget.createdAt = Date()
        budget.updatedAt = Date()
        budget.isAISuggested = false

        try context.save()

        let fetchRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 1)
        #expect(results.first?.name == "Groceries Budget")
        #expect((results.first?.limit as Decimal?)?.doubleValue == 500.00)
    }

    @Test func testBudgetWithTransactions() throws {
        let context = createTestContext()

        // Create budget
        let budget = Budget(context: context)
        budget.id = UUID()
        budget.name = "Dining Out Budget"
        budget.category = "Dining Out"
        budget.limit = NSDecimalNumber(value: 200.00)
        budget.period = "monthly"
        budget.startDate = Date()
        budget.createdAt = Date()
        budget.updatedAt = Date()

        // Create transactions
        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.amount = NSDecimalNumber(value: 50.00)
        transaction1.transactionDescription = "Coffee"
        transaction1.category = "Dining Out"
        transaction1.date = Date()
        transaction1.createdAt = Date()
        transaction1.updatedAt = Date()
        transaction1.budget = budget

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.amount = NSDecimalNumber(value: 75.00)
        transaction2.transactionDescription = "Dinner"
        transaction2.category = "Dining Out"
        transaction2.date = Date()
        transaction2.createdAt = Date()
        transaction2.updatedAt = Date()
        transaction2.budget = budget

        try context.save()

        // Test budget-transaction relationship
        #expect(budget.transactions?.count == 2)

        // Calculate total spending
        let totalSpent = (budget.transactions?.allObjects as? [Transaction])?.reduce(0.0) { sum, transaction in
            sum + ((transaction.amount as Decimal?)?.doubleValue ?? 0)
        } ?? 0

        #expect(totalSpent == 125.00)

        // Check if over budget
        let budgetLimit = (budget.limit as Decimal?)?.doubleValue ?? 0
        let isOverBudget = totalSpent > budgetLimit

        #expect(isOverBudget == false)
    }

    // MARK: - Savings Goal Tests

    @Test func testSavingsGoalCreation() throws {
        let context = createTestContext()

        let goal = SavingsGoal(context: context)
        goal.id = UUID()
        goal.name = "Emergency Fund"
        goal.targetAmount = NSDecimalNumber(value: 10000.00)
        goal.currentAmount = NSDecimalNumber(value: 2000.00)
        goal.deadline = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        goal.priority = 1
        goal.isAISuggested = true
        goal.aiStrategy = "Save 20% of monthly income"
        goal.createdAt = Date()
        goal.updatedAt = Date()
        goal.isCompleted = false

        try context.save()

        let fetchRequest: NSFetchRequest<SavingsGoal> = SavingsGoal.fetchRequest()
        let results = try context.fetch(fetchRequest)

        #expect(results.count == 1)
        #expect(results.first?.name == "Emergency Fund")
        #expect((results.first?.targetAmount as Decimal?)?.doubleValue == 10000.00)

        // Calculate progress percentage
        let current = (results.first?.currentAmount as Decimal?)?.doubleValue ?? 0
        let target = (results.first?.targetAmount as Decimal?)?.doubleValue ?? 1
        let progress = (current / target) * 100

        #expect(progress == 20.0)
    }

    @Test func testGoalCompletion() throws {
        let context = createTestContext()

        let goal = SavingsGoal(context: context)
        goal.id = UUID()
        goal.name = "Vacation Fund"
        goal.targetAmount = NSDecimalNumber(value: 1000.00)
        goal.currentAmount = NSDecimalNumber(value: 1000.00)
        goal.priority = 2
        goal.createdAt = Date()
        goal.updatedAt = Date()
        goal.isCompleted = false

        try context.save()

        // Check if goal should be marked complete
        let current = (goal.currentAmount as Decimal?)?.doubleValue ?? 0
        let target = (goal.targetAmount as Decimal?)?.doubleValue ?? 0

        if current >= target {
            goal.isCompleted = true
            try context.save()
        }

        #expect(goal.isCompleted == true)
    }

    // MARK: - Chat Message Tests

    @Test func testChatMessageCreation() throws {
        let context = createTestContext()
        let conversationId = UUID()

        let userMessage = ChatMessage(context: context)
        userMessage.id = UUID()
        userMessage.content = "How much did I spend on groceries?"
        userMessage.role = "user"
        userMessage.timestamp = Date()
        userMessage.conversationId = conversationId

        let assistantMessage = ChatMessage(context: context)
        assistantMessage.id = UUID()
        assistantMessage.content = "You spent $350 on groceries this month."
        assistantMessage.role = "assistant"
        assistantMessage.timestamp = Date()
        assistantMessage.conversationId = conversationId
        assistantMessage.tokensUsed = 42

        try context.save()

        let fetchRequest: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChatMessage.timestamp, ascending: true)]

        let results = try context.fetch(fetchRequest)

        #expect(results.count == 2)
        #expect(results.first?.role == "user")
        #expect(results.last?.role == "assistant")
        #expect(results.last?.tokensUsed == 42)
    }

    // MARK: - Financial Context Tests

    @Test func testTotalSpendingCalculation() throws {
        let context = createTestContext()
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!

        // Create transactions
        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.amount = NSDecimalNumber(value: 50.00)
        transaction1.transactionDescription = "Coffee"
        transaction1.category = "Dining Out"
        transaction1.date = Date()
        transaction1.createdAt = Date()
        transaction1.updatedAt = Date()

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.amount = NSDecimalNumber(value: 100.00)
        transaction2.transactionDescription = "Groceries"
        transaction2.category = "Groceries"
        transaction2.date = Date()
        transaction2.createdAt = Date()
        transaction2.updatedAt = Date()

        let transaction3 = Transaction(context: context)
        transaction3.id = UUID()
        transaction3.amount = NSDecimalNumber(value: 200.00)
        transaction3.transactionDescription = "Old Transaction"
        transaction3.category = "Other"
        transaction3.date = calendar.date(byAdding: .day, value: -60, to: Date())!
        transaction3.createdAt = Date()
        transaction3.updatedAt = Date()

        try context.save()

        // Fetch recent transactions (last 30 days)
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)

        let results = try context.fetch(fetchRequest)

        let totalSpending = results.reduce(0.0) { sum, transaction in
            sum + ((transaction.amount as Decimal?)?.doubleValue ?? 0)
        }

        #expect(results.count == 2) // Only recent transactions
        #expect(totalSpending == 150.00)
    }

    @Test func testCategoryTotals() throws {
        let context = createTestContext()

        // Create transactions in different categories
        let groceries1 = Transaction(context: context)
        groceries1.id = UUID()
        groceries1.amount = NSDecimalNumber(value: 100.00)
        groceries1.category = "Groceries"
        groceries1.transactionDescription = "Groceries 1"
        groceries1.date = Date()
        groceries1.createdAt = Date()
        groceries1.updatedAt = Date()

        let groceries2 = Transaction(context: context)
        groceries2.id = UUID()
        groceries2.amount = NSDecimalNumber(value: 150.00)
        groceries2.category = "Groceries"
        groceries2.transactionDescription = "Groceries 2"
        groceries2.date = Date()
        groceries2.createdAt = Date()
        groceries2.updatedAt = Date()

        let dining = Transaction(context: context)
        dining.id = UUID()
        dining.amount = NSDecimalNumber(value: 75.00)
        dining.category = "Dining Out"
        dining.transactionDescription = "Dinner"
        dining.date = Date()
        dining.createdAt = Date()
        dining.updatedAt = Date()

        try context.save()

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let results = try context.fetch(fetchRequest)

        var categoryTotals: [String: Double] = [:]
        for transaction in results {
            let category = transaction.category ?? "Uncategorized"
            let amount = (transaction.amount as Decimal?)?.doubleValue ?? 0
            categoryTotals[category, default: 0] += amount
        }

        #expect(categoryTotals["Groceries"] == 250.00)
        #expect(categoryTotals["Dining Out"] == 75.00)

        let topCategory = categoryTotals.max(by: { $0.value < $1.value })
        #expect(topCategory?.key == "Groceries")
    }
}
