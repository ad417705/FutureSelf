//
//  InsightsView.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import SwiftUI
import CoreData

struct InsightsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: InsightsViewModel
    @State private var showingProfile = false

    init(viewContext: NSManagedObjectContext) {
        let config = AzureConfig.load()!
        let aiService = AzureOpenAIService(config: config)
        _viewModel = StateObject(wrappedValue: InsightsViewModel(
            aiService: aiService,
            viewContext: viewContext
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    // Loading state
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.blue)

                        Text("Analyzing your spending...")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                } else if let error = viewModel.errorMessage {
                    // Error state
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(DesignSystem.Colors.warning.opacity(0.8))
                            .shadow(color: DesignSystem.Colors.warning.opacity(0.2), radius: 8)

                        Text("Couldn't Load Insights")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        Text(error)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.lg)

                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            Task {
                                await viewModel.loadInsights()
                            }
                        }) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "arrow.clockwise")
                                Text("Try Again")
                            }
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(Color.blue)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, y: 4)
                        }
                    }
                } else if viewModel.insights.isEmpty {
                    // Empty state
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(Color.blue.opacity(0.6))
                            .shadow(color: Color.blue.opacity(0.2), radius: 10)

                        Text("No Insights Yet")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        Text("Add some transactions and budgets to get AI-powered insights about your spending!")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                } else {
                    // Insights list
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.lg) {
                            ForEach(Array(viewModel.insights.enumerated()), id: \.element.title) { index, insight in
                                InsightCard(insight: insight)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                    }
                    .refreshable {
                        HapticManager.shared.lightImpact()
                        await viewModel.loadInsights()
                    }
                }
            }
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("Profile")
                    .accessibilityHint("Open profile and settings")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        Task {
                            await viewModel.loadInsights()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(viewModel.isLoading ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.luxuryGold)
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Refresh insights")
                    .accessibilityHint(viewModel.isLoading ? "Loading insights" : "Reload AI-powered insights")
                }
            }
            .task {
                // Auto-load insights on appear
                await viewModel.loadInsights()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSettingsView()
            }
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: InsightData

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header with icon and title
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon based on type
                Image(systemName: iconForType(insight.type))
                    .font(.title2)
                    .foregroundColor(colorForPriority(insight.priority))
                    .frame(width: 44, height: 44)
                    .background(colorForPriority(insight.priority).opacity(0.15))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .shadow(color: colorForPriority(insight.priority).opacity(0.2), radius: 4)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(insight.title)
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text(typeLabel(insight.type))
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()

                // Priority badge
                if insight.priority.lowercased() == "high" {
                    Text("High Priority")
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Colors.error.opacity(0.15))
                        .foregroundColor(DesignSystem.Colors.error)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                }
            }

            // Message
            Text(insight.message)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            // Actionable indicator
            if insight.actionable {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .font(DesignSystem.Typography.caption)
                    Text("Action suggested")
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(Color.blue)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(insight.priority) priority insight: \(insight.title)")
        .accessibilityValue(insight.message + (insight.actionable ? ". Action suggested." : ""))
    }

    // MARK: - Helpers

    private func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "pattern":
            return "chart.xyaxis.line"
        case "budget_alert":
            return "exclamationmark.triangle.fill"
        case "progress":
            return "checkmark.circle.fill"
        case "income_spending":
            return "dollarsign.circle.fill"
        default:
            return "info.circle.fill"
        }
    }

    private func colorForPriority(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high":
            return DesignSystem.Colors.error  // Red for negative/alerts
        case "medium":
            return DesignSystem.Colors.warning  // Orange/Yellow for moderate
        case "low":
            return DesignSystem.Colors.success  // Green for positive
        default:
            return Color.blue  // Blue for informational
        }
    }

    private func typeLabel(_ type: String) -> String {
        switch type.lowercased() {
        case "pattern":
            return "Spending Pattern"
        case "budget_alert":
            return "Budget Alert"
        case "progress":
            return "Progress Update"
        case "income_spending":
            return "Income vs Spending"
        default:
            return "Insight"
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return InsightsView(viewContext: context)
}
