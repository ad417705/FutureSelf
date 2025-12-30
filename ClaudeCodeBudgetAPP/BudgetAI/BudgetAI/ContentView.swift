//
//  ContentView.swift
//  BudgetAI
//
//  Created by Marcus Knighton on 12/25/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Transactions Tab
            TransactionListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
                .tag(0)

            // Income Tracker Tab
            IncomeTrackerView(viewContext: viewContext)
                .tabItem {
                    Label("Income", systemImage: "dollarsign.circle")
                }
                .tag(1)

            // FutureSelf Chat Tab
            ChatView(viewContext: viewContext)
                .tabItem {
                    Label("FutureSelf", systemImage: "sparkles")
                }
                .tag(2)

            // Insights Tab
            InsightsView(viewContext: viewContext)
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            // Goals Tab
            GoalsView(viewContext: viewContext)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(4)
        }
        .tint(DesignSystem.Colors.luxuryGold)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToFutureSelfTab"))) { _ in
            withAnimation {
                selectedTab = 2  // Switch to FutureSelf tab
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
