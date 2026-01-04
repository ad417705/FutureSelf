//  StabilityBarView.swift
import SwiftUI

struct StabilityBarView: View {
    let housingProgress: Double
    let utilitiesProgress: Double
    let foodProgress: Double

    private var overallProgress: Double {
        (housingProgress * 0.4 + utilitiesProgress * 0.3 + foodProgress * 0.3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month's Essentials")
                .font(.headline)

            GeometryReader { geometry in
                HStack(spacing: 2) {
                    // Housing segment (40%)
                    SegmentView(
                        progress: housingProgress,
                        color: .blue,
                        width: geometry.size.width * 0.4,
                        label: "Housing"
                    )

                    // Utilities segment (30%)
                    SegmentView(
                        progress: utilitiesProgress,
                        color: .teal,
                        width: geometry.size.width * 0.3,
                        label: "Utilities"
                    )

                    // Food segment (30%)
                    SegmentView(
                        progress: foodProgress,
                        color: .orange,
                        width: geometry.size.width * 0.3,
                        label: "Food"
                    )
                }
            }
            .frame(height: 32)

            // Milestones
            HStack(spacing: 12) {
                if housingProgress >= 0.5 {
                    MilestoneChip(icon: "house.fill", text: "Roof secured", color: .blue)
                }
                if utilitiesProgress >= 1.0 {
                    MilestoneChip(icon: "lightbulb.fill", text: "Lights on", color: .teal)
                }
                if foodProgress >= 0.5 {
                    MilestoneChip(icon: "fork.knife", text: "Fed", color: .orange)
                }
            }

            Text("You've funded \(Int(overallProgress * 100))% of essentials")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SegmentView: View {
    let progress: Double
    let color: Color
    let width: CGFloat
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                    .frame(width: width)

                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: width * min(1.0, progress))
            }
            .frame(height: 24)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: width)
        }
    }
}

struct MilestoneChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
