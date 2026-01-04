//  CrisisStreakView.swift
import SwiftUI

struct CrisisStreakView: View {
    let currentStreak: Int
    let longestStreak: Int

    private var weeks: [Bool] {
        // Show last 4 weeks
        (0..<4).map { $0 < currentStreak }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("No Crisis Week")
                    .font(.headline)
            }

            HStack(spacing: 8) {
                ForEach(weeks.indices, id: \.self) { index in
                    WeekBox(isClean: weeks[index], weekNumber: index + 1)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Current Streak:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentStreak) clean weeks")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                HStack {
                    Text("Longest Streak:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(longestStreak) weeks")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            if currentStreak >= 4 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("New milestone unlocked!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WeekBox: View {
    let isClean: Bool
    let weekNumber: Int

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(isClean ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Group {
                        if isClean {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                )

            Text("W\(weekNumber)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
