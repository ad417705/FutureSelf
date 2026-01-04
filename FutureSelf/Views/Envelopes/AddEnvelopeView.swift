//  AddEnvelopeView.swift
import SwiftUI

struct AddEnvelopeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var container: AppContainer

    @State private var name: String = ""
    @State private var budgetAmount: String = ""
    @State private var selectedIcon: String = "envelope.fill"
    @State private var selectedColor: String = "#007AFF"
    @State private var isEssential: Bool = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let availableIcons = [
        "envelope.fill", "house.fill", "bolt.fill", "fork.knife",
        "car.fill", "tv.fill", "bag.fill", "heart.fill",
        "book.fill", "airplane", "person.2.fill", "briefcase.fill"
    ]

    private let availableColors = [
        "#007AFF", "#3B82F6", "#14B8A6", "#22C55E",
        "#F97316", "#A855F7", "#EC4899", "#EF4444"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Envelope Name", text: $name)

                    HStack {
                        Text("$")
                        TextField("0.00", text: $budgetAmount)
                            .keyboardType(.decimalPad)
                    }

                    Toggle("Essential Expense", isOn: $isEssential)
                        .tint(.green)
                }

                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Button {
                                selectedColor = colorHex
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white, lineWidth: selectedColor == colorHex ? 3 : 0)
                                    )
                                    .shadow(radius: selectedColor == colorHex ? 4 : 0)
                            }
                        }
                    }
                }

                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundColor(Color(hex: selectedColor))
                        Text(name.isEmpty ? "Preview" : name)
                            .font(.headline)
                        Spacer()
                        if isEssential {
                            Text("Essential")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .navigationTitle("New Envelope")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEnvelope()
                    }
                    .disabled(!isValid || isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !budgetAmount.isEmpty && Decimal(string: budgetAmount) != nil
    }

    private func saveEnvelope() {
        guard let budget = Decimal(string: budgetAmount) else {
            errorMessage = "Invalid budget amount"
            showError = true
            return
        }

        isLoading = true

        Task {
            do {
                let envelope = Envelope(
                    userId: container.currentUser.id,
                    name: name,
                    budgetAmount: budget,
                    spentAmount: 0,
                    iconName: selectedIcon,
                    colorHex: selectedColor,
                    isEssential: isEssential
                )

                _ = try await container.envelopeService.createEnvelope(envelope)
                dismiss()
            } catch {
                errorMessage = "Failed to save envelope: \(error.localizedDescription)"
                showError = true
                isLoading = false
            }
        }
    }
}

#Preview {
    AddEnvelopeView()
        .environmentObject(AppContainer.shared)
}
