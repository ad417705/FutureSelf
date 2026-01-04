//  GoalsListView.swift
import SwiftUI

struct GoalsListView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel: GoalsViewModel
    @State private var showingAddGoal = false
    @State private var selectedGoal: Goal?

    init() {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(
            goalService: AppContainer.shared.goalService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Active Goal - Featured
                        if let activeGoal = viewModel.goals.first(where: { $0.isActive }) {
                            NavigationLink(destination: FutureSelfView(goal: activeGoal)) {
                                FeaturedGoalCard(goal: activeGoal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // All Goals
                        ForEach(viewModel.goals) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal)) {
                                GoalCard(goal: goal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        if viewModel.goals.isEmpty && !viewModel.isLoading {
                            EmptyGoalsView()
                        }
                    }
                    .padding()
                }

                if viewModel.isLoading && viewModel.goals.isEmpty {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .task { await viewModel.loadGoals() }
        }
    }
}

struct FeaturedGoalCard: View {
    let goal: Goal

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: goal.type.icon)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Goal")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text(goal.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
            }

            ProgressView(value: goal.progress)
                .tint(.white)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(Int(goal.progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Saved")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    if let target = goal.targetAmount {
                        Text("\(goal.currentAmount as NSDecimalNumber, formatter: currencyFormatter) / \(target as NSDecimalNumber, formatter: currencyFormatter)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct GoalCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundColor(.blue)
                Text(goal.name).font(.headline)
                Spacer()
                if goal.isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            Text(goal.description).font(.caption).foregroundColor(.secondary)
            if let target = goal.targetAmount {
                ProgressView(value: goal.progress)
                HStack {
                    Text("\(goal.currentAmount as NSDecimalNumber, formatter: currencyFormatter)")
                    Text("of \(target as NSDecimalNumber, formatter: currencyFormatter)")
                        .font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(goal.progress * 100))%")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EmptyGoalsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Goals Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Set your first goal to start building your FutureSelf")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Tap the + button above to create a goal")
                .font(.caption)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("Popular goals:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                HStack(spacing: 8) {
                    MiniGoalSuggestion(icon: "shield.fill", text: "Emergency Fund")
                    MiniGoalSuggestion(icon: "creditcard.fill", text: "Debt Free")
                }
                HStack(spacing: 8) {
                    MiniGoalSuggestion(icon: "house.fill", text: "Move Out")
                    MiniGoalSuggestion(icon: "airplane", text: "Travel")
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

struct MiniGoalSuggestion: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(6)
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.maximumFractionDigits = 0
    return f
}()

#Preview {
    GoalsListView()
        .environmentObject(AppContainer.shared)
}
