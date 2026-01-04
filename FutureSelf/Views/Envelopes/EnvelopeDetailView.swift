//  EnvelopeDetailView.swift
import SwiftUI

struct EnvelopeDetailView: View {
    @EnvironmentObject var container: AppContainer
    let envelope: Envelope

    @State private var transactions: [Transaction] = []
    @State private var isLoading = false
    @State private var showingEditSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Envelope Header
                VStack(spacing: 12) {
                    Image(systemName: envelope.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(envelope.color)

                    Text(envelope.name)
                        .font(.title)
                        .fontWeight(.bold)

                    if envelope.isEssential {
                        Text("Essential Expense")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Budget Summary
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(envelope.spentAmount as NSDecimalNumber, formatter: currencyFormatter)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Budget")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(envelope.budgetAmount as NSDecimalNumber, formatter: currencyFormatter)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(envelope.status.color)
                                .frame(width: geometry.size.width * envelope.percentUsed, height: 12)
                        }
                    }
                    .frame(height: 12)

                    HStack {
                        Text("\(Int(envelope.percentUsed * 100))% used")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(envelope.status.displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(envelope.status.color)
                    }

                    HStack {
                        Text("Remaining")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(envelope.remaining as NSDecimalNumber, formatter: currencyFormatter)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(envelope.remaining < 0 ? .red : .green)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Transactions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transactions")
                        .font(.headline)

                    if transactions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No transactions yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                    } else {
                        ForEach(transactions) { transaction in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.description)
                                        .font(.subheadline)
                                    Text(transaction.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text("\(transaction.amount as NSDecimalNumber, formatter: currencyFormatter)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 8)

                            if transaction.id != transactions.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle(envelope.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadTransactions()
        }
    }

    private func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allTransactions = try await container.transactionService.getTransactions()
            // Filter transactions for this envelope (in a real app, this would be server-side)
            // For now, filter by matching category or amount
            transactions = allTransactions.filter { tx in
                tx.category.displayName == envelope.name ||
                (tx.amount == envelope.spentAmount && envelope.spentAmount > 0)
            }
        } catch {
            print("Error loading transactions: \(error)")
        }
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.maximumFractionDigits = 0
    return f
}()
