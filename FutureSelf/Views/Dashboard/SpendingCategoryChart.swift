//  SpendingCategoryChart.swift
import SwiftUI
import Charts

struct SpendingCategoryChart: View {
    let categories: [CategorySpending]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)

            if categories.isEmpty {
                Text("No spending data yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            } else {
                Chart(categories.prefix(5)) { category in
                    SectorMark(
                        angle: .value("Amount", category.amount.asDouble),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(categoryColor(for: category.category))
                    .cornerRadius(4)
                }
                .frame(height: 200)

                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(categories.prefix(5)) { category in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(categoryColor(for: category.category))
                                .frame(width: 10, height: 10)
                            Text(category.category.displayName)
                                .font(.caption)
                            Spacer()
                            Text(category.percentageString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func categoryColor(for category: TransactionCategory) -> Color {
        switch category {
        case .housing: return .blue
        case .utilities: return .teal
        case .transportation: return .orange
        case .food: return .green
        case .entertainment: return .purple
        case .income: return .green
        case .other: return .gray
        }
    }
}

extension CategorySpending {
    var percentageString: String {
        String(format: "%.0f%%", percentage * 100)
    }
}
