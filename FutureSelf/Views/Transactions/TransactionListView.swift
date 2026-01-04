//  TransactionListView.swift
import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel: TransactionsViewModel
    @State private var showingAddTransaction = false

    init() {
        _viewModel = StateObject(wrappedValue: TransactionsViewModel(
            transactionService: AppContainer.shared.transactionService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.transactions.isEmpty && !viewModel.isLoading {
                    EmptyTransactionsView()
                } else {
                    List {
                        ForEach(viewModel.transactions) { tx in
                            HStack {
                                Image(systemName: tx.category.icon).foregroundColor(.accentColor)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tx.description).font(.body)
                                    Text(tx.date, style: .date).font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(tx.amount as NSDecimalNumber, formatter: currencyFormatter)")
                                    .foregroundColor(tx.amount > 0 ? .red : .green)
                            }
                        }
                    }
                }

                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .task { await viewModel.loadTransactions() }
        }
    }
}

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Transactions Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Start tracking your spending by adding your first transaction")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Tap the + button above to add a transaction")
                .font(.caption)
                .foregroundColor(.accentColor)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    return f
}()
