//  AddTransactionView.swift
import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var container: AppContainer

    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var category: TransactionCategory = .food
    @State private var selectedEnvelope: Envelope?
    @State private var date: Date = Date()
    @State private var isExpense: Bool = true
    @State private var envelopes: [Envelope] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Description", text: $description)

                    HStack {
                        Text("$")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                if isExpense {
                    Section("Category") {
                        Picker("Category", selection: $category) {
                            ForEach(TransactionCategory.allCases.filter { $0 != .income }, id: \.self) { cat in
                                HStack {
                                    Image(systemName: cat.icon)
                                    Text(cat.displayName)
                                }
                                .tag(cat)
                            }
                        }
                    }

                    Section("Envelope") {
                        if envelopes.isEmpty {
                            Text("No envelopes available")
                                .foregroundColor(.secondary)
                        } else {
                            Picker("Assign to Envelope", selection: $selectedEnvelope) {
                                Text("None").tag(nil as Envelope?)
                                ForEach(envelopes) { envelope in
                                    HStack {
                                        Image(systemName: envelope.iconName)
                                        Text(envelope.name)
                                    }
                                    .tag(envelope as Envelope?)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isExpense ? "Add Expense" : "Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValid || isLoading)
                }
            }
            .task {
                await loadEnvelopes()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isValid: Bool {
        !description.isEmpty && !amount.isEmpty && Decimal(string: amount) != nil
    }

    private func loadEnvelopes() async {
        do {
            envelopes = try await container.envelopeService.getEnvelopes()
        } catch {
            print("Error loading envelopes: \(error)")
        }
    }

    private func saveTransaction() {
        guard let amountDecimal = Decimal(string: amount) else {
            errorMessage = "Invalid amount"
            showError = true
            return
        }

        isLoading = true

        Task {
            do {
                let finalAmount = isExpense ? amountDecimal : -amountDecimal
                let finalCategory = isExpense ? category : .income

                let transaction = Transaction(
                    userId: container.currentUser.id,
                    amount: finalAmount,
                    description: description,
                    category: finalCategory,
                    date: date
                )

                _ = try await container.transactionService.createTransaction(transaction)

                // Update envelope if selected
                if isExpense, let envelope = selectedEnvelope {
                    try await container.envelopeService.addSpending(envelopeId: envelope.id, amount: amountDecimal)
                }

                dismiss()
            } catch {
                errorMessage = "Failed to save transaction: \(error.localizedDescription)"
                showError = true
                isLoading = false
            }
        }
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(AppContainer.shared)
}
