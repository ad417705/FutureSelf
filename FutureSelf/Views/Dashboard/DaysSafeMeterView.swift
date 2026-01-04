//  DaysSafeMeterView.swift
import SwiftUI

struct DaysSafeMeterView: View {
    let daysCovered: Int
    let goalDays: Int = 30

    private var progress: Double {
        min(1.0, Double(daysCovered) / Double(goalDays))
    }

    private var ringColor: Color {
        if daysCovered < 4 { return .red }
        if daysCovered < 14 { return .orange }
        return .green
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Days Safe Meter")
                .font(.headline)

            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                    .frame(width: 150, height: 150)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: daysCovered)

                // Center text
                VStack(spacing: 4) {
                    Text("\(daysCovered)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(ringColor)
                    Text("days safe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text("Goal: \(goalDays) days")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("+1 day every time you add $15")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Milestone tokens
            HStack(spacing: 12) {
                if daysCovered >= 3 {
                    MilestoneToken(icon: "cart.fill", text: "Food buffer", color: .green)
                }
                if daysCovered >= 7 {
                    MilestoneToken(icon: "calendar", text: "1 week safe", color: .blue)
                }
                if daysCovered >= 14 {
                    MilestoneToken(icon: "shield.fill", text: "2-week shield", color: .purple)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MilestoneToken: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 70)
    }
}
