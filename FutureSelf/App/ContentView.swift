//
//  ContentView.swift
//  FutureSelf
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var container: AppContainer
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            EnvelopeListView()
                .tabItem {
                    Label("Envelopes", systemImage: "envelope.fill")
                }
                .tag(1)

            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
                .tag(2)

            GoalsListView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(3)

            AIChatView()
                .tabItem {
                    Label("AI Coach", systemImage: "message.fill")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "#6366F1"))
    }
}
