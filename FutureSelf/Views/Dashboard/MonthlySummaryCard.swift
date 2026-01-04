//  MonthlySummaryCard.swift
import SwiftUI

struct MonthlySummaryCard: View {
    let spent: Decimal
    let budget: Decimal

    private var percentUsed: Double {
        guard budget > 0 else { return 0 }
        return min(1.0, (spent / budget).asDouble)
    }

    private var status: BudgetStatus {
        if percentUsed >= 1.0 { return .danger }
        if percentUsed >= 0.8 { return .warning }
        return .good
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Summary")
                .font(.headline)

            HStack(alignment: .firstTextBaseline) {
                Text("Spent: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(spent as NSDecimalNumber, formatter: currencyFormatter)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("/ \(budget as NSDecimalNumber, formatter: currencyFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(status.color)
                        .frame(width: geometry.size.width * percentUsed, height: 8)
                        .animation(.easeInOut(duration: 0.6), value: percentUsed)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(percentUsed * 100))% used")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(status.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(status.color)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.maximumFractionDigits = 0
    return f
}()
