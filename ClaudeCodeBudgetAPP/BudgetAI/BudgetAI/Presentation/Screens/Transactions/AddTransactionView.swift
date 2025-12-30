//
//  AddTransactionView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddTransactionViewModel

    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)

                    TextField("Description", text: $viewModel.description)

                    DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveTransaction() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let repository = TransactionRepository(context: context)
    let viewModel = AddTransactionViewModel(repository: repository)

    return AddTransactionView(viewModel: viewModel)
}
