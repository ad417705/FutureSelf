//
//  TransactionListView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct TransactionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTransaction = false
    @State private var showingProfile = false
    @State private var refreshID = UUID()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    // Count uncategorized transactions
    private var uncategorizedCount: Int {
        let count = transactions.filter { $0.category == "Uncategorized" }.count
        print("🔍 Uncategorized count: \(count)")
        return count
    }

    var body: some View {
        NavigationView {
            List {
                // AI Natural Language Input Section
                Section {
                    NaturalLanguageInputView()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                // FutureSelf Banner Section
                if uncategorizedCount > 0 {
                    Section {
                        FutureSelfBanner(uncategorizedCount: uncategorizedCount)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }

                // Transactions Section
                Section {
                    if transactions.isEmpty {
                        // Empty state
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(DesignSystem.Colors.luxuryGold.opacity(0.6))
                                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.2), radius: 10)

                            Text("No Transactions")
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.primaryText)

                            Text("Use AI to add transactions above or tap + button")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xxl)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                            TransactionRow(transaction: transaction)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                                    removal: .scale(scale: 0.8).combined(with: .opacity)
                                ))
                                .onAppear {
                                    print("📋 Transaction: \(transaction.transactionDescription ?? "Unknown") - Category: \(transaction.category ?? "nil")")
                                }
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .id(refreshID)
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.primaryBackground)
            .navigationTitle("Transactions")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("Profile")
                    .accessibilityHint("Open profile and settings")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction = true }) {
                        Label("Add Transaction", systemImage: "plus")
                    }
                    .accessibilityLabel("Add Transaction")
                    .accessibilityHint("Open form to add a new transaction")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TransactionCategorized"))) { _ in
                print("🔔 Received TransactionCategorized notification - refreshing list")
                viewContext.refreshAllObjects()
                refreshID = UUID()
            }
            .sheet(isPresented: $showingAddTransaction) {
                let repository = TransactionRepository(context: viewContext)
                let viewModel = AddTransactionViewModel(repository: repository)
                AddTransactionView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSettingsView()
            }
        }
    }

    private func deleteTransactions(at offsets: IndexSet) {
        withAnimation(DesignSystem.Animations.premium) {
            offsets.map { transactions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                HapticManager.shared.success()
            } catch {
                let nsError = error as NSError
                print("Error deleting transaction: \(nsError), \(nsError.userInfo)")
                HapticManager.shared.error()
            }
        }
    }
}

// MARK: - FutureSelf Banner

struct FutureSelfBanner: View {
    let uncategorizedCount: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: {
            // Post notification to switch to FutureSelf tab
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToFutureSelfTab"), object: nil)
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.luxuryGold)
                    .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Talk to FutureSelf")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text("You have \(uncategorizedCount) uncategorized transaction\(uncategorizedCount == 1 ? "" : "s"). I can help categorize them!")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(DesignSystem.Colors.luxuryGold)
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(DesignSystem.Colors.luxuryGold.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text(transaction.transactionDescription ?? "Unknown")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                HStack(spacing: DesignSystem.Spacing.sm) {
                    // Category badge - highlight uncategorized with gold
                    Text(transaction.category ?? "Uncategorized")
                        .font(DesignSystem.Typography.caption)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            transaction.category == "Uncategorized" ?
                                DesignSystem.Colors.luxuryGold.opacity(0.15) :
                                DesignSystem.Colors.elevatedBackground
                        )
                        .foregroundColor(
                            transaction.category == "Uncategorized" ?
                                DesignSystem.Colors.luxuryGold :
                                DesignSystem.Colors.secondaryText
                        )
                        .cornerRadius(DesignSystem.CornerRadius.small)

                    Text(transaction.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)

                    // AI badge if processed by AI
                    if transaction.isAIProcessed {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundColor(DesignSystem.Colors.luxuryGold)
                            .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 4)
                    }
                }
            }

            Spacer()

            Text((transaction.amount as Decimal?)?.toCurrencyString() ?? "$0.00")
                .font(DesignSystem.Typography.bodyBold)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.transactionDescription ?? "Unknown"), \((transaction.amount as Decimal?)?.toCurrencyString() ?? "$0.00")")
        .accessibilityValue("Category: \(transaction.category ?? "Uncategorized"), Date: \(transaction.date?.formatted(date: .abbreviated, time: .omitted) ?? "")\(transaction.isAIProcessed ? ", Processed by AI" : "")")
        .accessibilityHint("Swipe left to delete")
    }
}

#Preview {
    TransactionListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
