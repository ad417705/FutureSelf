//  GoalSelectionView.swift
import SwiftUI

struct GoalSelectionView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Text("What's Your Goal?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose what you're saving for")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // Goal type grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(GoalType.allCases, id: \.self) { type in
                        GoalTypeCard(
                            goalType: type,
                            isSelected: coordinator.progress.collectedData.goalType == type
                        ) {
                            coordinator.progress.collectedData.goalType = type
                        }
                    }
                }
                .padding()
            }

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                Button("Back") {
                    coordinator.goBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Button("Continue") {
                    coordinator.advance()
                }
                .disabled(coordinator.progress.collectedData.goalType == nil)
                .frame(maxWidth: .infinity)
                .padding()
                .background(coordinator.progress.collectedData.goalType != nil ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .padding()
    }
}

struct GoalTypeCard: View {
    let goalType: GoalType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goalType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(goalType.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
