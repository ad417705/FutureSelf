//  BillBossView.swift
import SwiftUI

struct BillBossView: View {
    let envelopes: [Envelope]

    private var billEnvelopes: [Envelope] {
        envelopes.filter { $0.isEssential }.prefix(3).map { $0 }
    }

    private var allBillsPaid: Bool {
        billEnvelopes.allSatisfy { $0.percentUsed >= 1.0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bill Boss Challenges")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 16) {
                ForEach(billEnvelopes) { bill in
                    ThermometerBar(
                        name: bill.name,
                        progress: bill.percentUsed,
                        color: bill.color
                    )
                }
            }
            .frame(height: 140)

            if allBillsPaid {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No Crisis Month!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ThermometerBar: View {
    let name: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 120)

                // Progress fill
                RoundedRectangle(cornerRadius: 8)
                    .fill(progress >= 1.0 ? Color.green : color)
                    .frame(width: 50, height: 120 * min(1.0, progress))

                // 50% goal flag
                if progress >= 0.5 {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                        .offset(y: -60)
                }

                // Checkmark at 100%
                if progress >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }

            Text(name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 70)

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
