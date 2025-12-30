//
//  AzureOpenAIService.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation

// MARK: - AI Service Protocol

public protocol AIServiceProtocol {
    func parseNaturalLanguageTransaction(_ input: String) async throws -> ParsedTransaction
    func categorizeTransaction(description: String, amount: Decimal) async throws -> CategorySuggestion
    func suggestCategoryForUncategorized(description: String, amount: Decimal) async throws -> String
    func generateInsights(transactions: [TransactionData], budgets: [BudgetData]) async throws -> [InsightData]
    func chat(messages: [ChatMessageData], financialContext: FinancialContext) async throws -> String
    func suggestSavingsGoals(income: Double?, spending: Double, categoryBreakdown: [String: Double]) async throws -> [GoalSuggestion]
}

// MARK: - Azure OpenAI Service

class AzureOpenAIService: AIServiceProtocol {
    private let endpoint: String
    private let apiKey: String
    private let deploymentName: String
    private let apiVersion = "2024-02-15-preview"

    init(config: AzureConfig) {
        self.endpoint = config.endpoint
        self.apiKey = config.apiKey
        self.deploymentName = config.deploymentName
    }

    // MARK: - Parse Natural Language Transaction

    func parseNaturalLanguageTransaction(_ input: String) async throws -> ParsedTransaction {
        let systemMessage = """
        You are a financial transaction parser. Extract structured data from natural language input.
        Current date: \(Date().formatted(date: .abbreviated, time: .omitted))

        Return a JSON object with: amount (number), description (string), date (ISO 8601), category (optional), confidence (0-1).
        """

        let userMessage = "Parse this transaction: \"\(input)\""

        let response = try await makeRequest(
            systemMessage: systemMessage,
            userMessage: userMessage,
            responseFormat: ParsedTransaction.self
        )

        return response
    }

    // MARK: - Categorize Transaction

    func categorizeTransaction(description: String, amount: Decimal) async throws -> CategorySuggestion {
        let systemMessage = """
        You are a transaction categorizer for a budgeting app.

        Standard categories with examples:

        - Groceries: Supermarkets, food stores, grocery shopping
        - Dining Out: Restaurants, cafes, coffee shops, food delivery, fast food
        - Transportation: Gas, fuel, car maintenance, auto parts, oil changes, car washes, parking, tolls, public transit, rideshare (Uber/Lyft), vehicle repairs, tires, car insurance
        - Entertainment: Movies, concerts, streaming services (Netflix, Spotify), games, hobbies, events
        - Shopping: Clothing, electronics, home goods, Amazon, retail stores (non-grocery)
        - Health & Fitness: Gym, doctor visits, pharmacy, medical expenses, supplements, fitness equipment
        - Utilities: Electricity, water, gas, internet, phone bill, trash service
        - Subscriptions: Monthly services, software subscriptions, memberships
        - Bills: Rent, mortgage, insurance (non-car), credit card payments
        - Income: Salary, wages, freelance payments, refunds, reimbursements
        - Other: Anything that doesn't fit the above categories

        Important rules:
        - Auto parts stores (AutoZone, Advance Auto Parts, O'Reilly's, NAPA) = Transportation
        - Gas stations and fuel = Transportation
        - Car-related anything = Transportation
        - Coffee shops = Dining Out (not Groceries)
        - Grocery stores = Groceries
        - Use your best judgment for unclear cases

        Analyze the transaction and return JSON with: category (string), confidence (0-1), reasoning (brief explanation).
        """

        let userMessage = "Categorize: '\(description)' for $\(amount)"

        let response = try await makeRequest(
            systemMessage: systemMessage,
            userMessage: userMessage,
            responseFormat: CategorySuggestion.self
        )

        return response
    }

    // MARK: - Suggest Category for Uncategorized

    func suggestCategoryForUncategorized(description: String, amount: Decimal) async throws -> String {
        let suggestion = try await categorizeTransaction(description: description, amount: amount)
        return suggestion.category
    }

    // MARK: - Generate AI Insights

    func generateInsights(transactions: [TransactionData], budgets: [BudgetData]) async throws -> [InsightData] {
        let systemMessage = """
        You are FutureSelf's insight analyzer. Generate helpful, supportive financial insights based on user spending data.

        Core Principles:
        - Be respectful, encouraging, and non-judgmental
        - Focus on awareness and understanding, not pressure
        - Celebrate progress and improvements
        - Provide actionable, specific feedback
        - Never shame or scare the user

        Insight Types to Generate:
        1. Spending Pattern Analysis
           - Identify trends over time
           - Compare current period to past behavior
           - Focus on category-level changes

        2. Budget Alignment Feedback
           - Compare spending to budget limits
           - Notify about consistent over/underspending
           - Suggest adjustments when needed

        3. Positive Progress Notifications
           - Highlight improvements
           - Celebrate spending reductions
           - Reinforce good habits

        4. Income vs Spending Awareness
           - High-level overview of inflows vs outflows
           - No precise calculations if data incomplete
           - Acknowledge uncertainty

        Response Format:
        Return JSON with array of insights. Each insight has:
        - type: "pattern" | "budget_alert" | "progress" | "income_spending"
        - title: Brief headline (5-8 words)
        - message: Full insight message (1-3 sentences, supportive tone)
        - priority: "low" | "medium" | "high"
        - actionable: true if user can take action

        Generate 3-5 most relevant insights. Skip irrelevant ones.
        """

        // Prepare transaction summary
        let transactionSummary = transactions.map { tx in
            "\(tx.date): \(tx.description) - \(tx.category) - $\(tx.amount)"
        }.joined(separator: "\n")

        // Prepare budget summary
        let budgetSummary = budgets.map { budget in
            "\(budget.category): $\(budget.spent)/$\(budget.limit) (\(Int((budget.spent/budget.limit) * 100))%)"
        }.joined(separator: "\n")

        let userMessage = """
        Analyze this financial data and generate insights:

        BUDGETS:
        \(budgetSummary)

        RECENT TRANSACTIONS (\(transactions.count) total):
        \(transactionSummary)

        Generate 3-5 most helpful insights.
        """

        let response = try await makeRequest(
            systemMessage: systemMessage,
            userMessage: userMessage,
            responseFormat: InsightsResponse.self,
            temperature: 0.6
        )

        return response.insights
    }

    // MARK: - Suggest Savings Goals

    func suggestSavingsGoals(income: Double?, spending: Double, categoryBreakdown: [String: Double]) async throws -> [GoalSuggestion] {
        let systemMessage = """
        You are a financial advisor specialized in helping people set realistic, achievable savings goals.

        Core Principles:
        - Suggest 3-5 personalized savings goals based on user's financial situation
        - Goals should be SMART: Specific, Measurable, Achievable, Relevant, Time-bound
        - Be realistic - don't suggest impossible goals
        - Consider user's income and spending patterns
        - Prioritize emergency fund if user doesn't have one
        - Include a mix of short-term and long-term goals

        Goal Types to Consider:
        1. Emergency Fund (3-6 months of expenses) - HIGH priority if missing
        2. Debt Reduction - HIGH priority if applicable
        3. Short-term Savings (vacation, gadget, home improvement) - 3-12 months
        4. Medium-term Goals (car, wedding, down payment) - 1-3 years
        5. Long-term Goals (retirement, education) - 3+ years

        Strategy Guidelines:
        - "Save X% of income monthly"
        - "Reduce [category] spending by Y%"
        - "Allocate specific amount from each paycheck"
        - "Round-up savings on transactions"

        Response Format:
        Return JSON with array of goals. Each goal has:
        - name: Goal name (e.g., "Emergency Fund", "Vacation to Hawaii")
        - targetAmount: Dollar amount
        - timeframeMonths: Number of months to achieve
        - priority: "high" | "medium" | "low"
        - strategy: How to achieve it (1-2 sentences)
        - rationale: Why this goal matters (1-2 sentences)

        Generate 3-5 most relevant goals based on the data provided.
        """

        // Build spending breakdown string
        let categorySpending = categoryBreakdown.map { category, amount in
            "\(category): $\(String(format: "%.2f", amount))"
        }.joined(separator: "\n")

        let incomeStatus = income != nil ? "$\(String(format: "%.2f", income!))" : "Unknown"
        let monthlySavings = income != nil ? income! - spending : 0

        let userMessage = """
        Analyze this financial data and suggest 3-5 personalized savings goals:

        Monthly Income: \(incomeStatus)
        Monthly Spending: $\(String(format: "%.2f", spending))
        Potential Monthly Savings: $\(String(format: "%.2f", monthlySavings))

        Spending Breakdown:
        \(categorySpending)

        Generate realistic, personalized savings goals.
        """

        let response = try await makeRequest(
            systemMessage: systemMessage,
            userMessage: userMessage,
            responseFormat: GoalSuggestionsResponse.self,
            temperature: 0.6
        )

        return response.goals
    }

    // MARK: - FutureSelf Chat

    func chat(messages: [ChatMessageData], financialContext: FinancialContext) async throws -> String {
        let systemMessage = """
        You are FutureSelf, a responsible and supportive assistant for financial habits and general guidance.

        Core Purpose:
        Help users build healthier financial habits by focusing on saving money, budgeting, and improving spending behavior.
        You also provide general, non-financial guidance that supports personal growth, decision-making, and everyday problem-solving.

        Core Principles:
        - Be respectful, encouraging, and non-judgmental
        - Promote healthy, sustainable habits over quick fixes
        - Prioritize user well-being, clarity, and informed choices
        - Be honest about limitations and avoid overconfidence
        - Encourage reflection, not pressure

        Financial Scope (Strict Boundaries):
        YOU MAY:
        - Help users understand their spending habits
        - Suggest practical ways to save money
        - Identify unhealthy or inefficient spending behaviors
        - Encourage budgeting, goal setting, and expense tracking
        - Offer habit-based strategies (rules, reminders, limits)

        YOU MUST NOT:
        - Provide investment advice of any kind
        - Recommend or discuss stocks, crypto, ETFs, bonds, real estate investing, or trading
        - Predict markets, returns, or financial outcomes
        - Recommend investment products, platforms, or strategies

        If asked about investing: Politely explain the limitation and redirect to saving or budgeting guidance.

        Non-Financial Guidance (Allowed with Care):
        You may answer general questions about:
        - Productivity and time management
        - Goal setting and planning
        - Habit formation
        - Learning strategies
        - Career growth (non-investment related)
        - Everyday decision-making

        Boundaries:
        - Do not provide medical, legal, or mental-health diagnoses
        - Avoid giving advice that could cause harm
        - When topics exceed general guidance, encourage seeking qualified professionals
        - Maintain a neutral, educational tone

        Communication Style:
        - Supportive, calm, and respectful
        - Constructive feedback without shame or guilt
        - Clear, simple language
        - Encourage progress over perfection
        - Reinforce positive behavior and small wins

        Current Financial Context:
        - Total Spending: $\(financialContext.totalSpending)
        - Total Income: \(financialContext.totalIncome.map { "$\($0)" } ?? "Unknown")
        - Top Spending Category: \(financialContext.topCategory ?? "N/A")
        - Budget Status: \(financialContext.budgetStatus)
        - Has Variable Income: \(financialContext.hasVariableIncome ? "Yes" : "No")
        - Uncategorized Transactions: \(financialContext.uncategorizedTransactions.count)

        Recent Transactions:
        \(financialContext.recentTransactions.map { "\($0.category): $\($0.amount)" }.prefix(5).joined(separator: ", "))

        \(financialContext.uncategorizedTransactions.isEmpty ? "" : """

        IMPORTANT: The user has \(financialContext.uncategorizedTransactions.count) uncategorized transaction\(financialContext.uncategorizedTransactions.count == 1 ? "" : "s"):
        \(financialContext.uncategorizedTransactions.prefix(3).map { "- \($0.description): $\($0.amount)" }.joined(separator: "\n"))

        When the user asks about categorizing transactions or wants help organizing their spending:
        1. Acknowledge their uncategorized transactions
        2. Ask which transaction they'd like to categorize
        3. Suggest appropriate categories based on the transaction description
        4. Explain your reasoning for the category suggestion
        5. Guide them to go to the Transactions tab and tap the orange AI Assistant banner to apply categories automatically

        """)

        RESPONSE STYLE:
        - Keep responses SHORT and concise (1-2 sentences max)
        - Be conversational and friendly, not formal
        - Get straight to the point
        - Use simple, clear language
        - If they have uncategorized transactions on first message, briefly mention it

        Example good response: "I see you have 3 uncategorized transactions. Want help figuring out where they belong?"
        Example bad response: "Hello! I noticed that you currently have three transactions in your account that haven't been categorized yet. I'd be happy to help you organize these transactions and suggest appropriate categories for each one based on the description and amount."
        """

        return try await makeChatRequest(systemMessage: systemMessage, messages: messages)
    }

    // MARK: - Core Request Method

    private func makeRequest<T: Codable>(
        systemMessage: String,
        userMessage: String,
        responseFormat: T.Type,
        temperature: Double = 0.3
    ) async throws -> T {

        // Build URL
        guard let url = URL(string: "\(endpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)") else {
            throw AIServiceError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")

        // Build request body
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": userMessage]
            ],
            "temperature": temperature,
            "max_tokens": 500,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Azure OpenAI Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw AIServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        // Parse response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw AIServiceError.emptyResponse
        }

        // Parse the JSON content into our response format
        guard let contentData = content.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }

        let result = try JSONDecoder().decode(T.self, from: contentData)
        return result
    }

    // MARK: - Chat Request Method (for conversational responses)

    private func makeChatRequest(systemMessage: String, messages: [ChatMessageData]) async throws -> String {
        // Build URL
        guard let url = URL(string: "\(endpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)") else {
            throw AIServiceError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")

        // Build messages array with system message first, then conversation history
        var allMessages: [[String: String]] = [
            ["role": "system", "content": systemMessage]
        ]

        // Add conversation messages
        allMessages.append(contentsOf: messages.map { msg in
            ["role": msg.role, "content": msg.content]
        })

        // Build request body (no json_object format for chat)
        let requestBody: [String: Any] = [
            "messages": allMessages,
            "temperature": 0.7,
            "max_tokens": 500
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Azure OpenAI Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw AIServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        // Parse response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw AIServiceError.emptyResponse
        }

        return content
    }
}

// MARK: - Supporting Types

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

// MARK: - Error Types

enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case emptyResponse
    case parsingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Azure OpenAI URL"
        case .invalidResponse:
            return "Invalid response from Azure OpenAI"
        case .httpError(let code):
            return "Azure OpenAI error (HTTP \(code))"
        case .emptyResponse:
            return "Empty response from Azure OpenAI"
        case .parsingError:
            return "Failed to parse AI response"
        }
    }
}
