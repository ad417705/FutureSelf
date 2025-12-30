//
//  BudgetAIApp.swift
//  BudgetAI
//
//  Created by Marcus Knighton on 12/25/25.
//

import SwiftUI
import CoreData

@main
struct BudgetAIApp: App {
    let persistenceController = PersistenceController.shared

    init() {
              // Test: Load Azure configuration
              if let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
                 let config = NSDictionary(contentsOfFile: path) as? [String: Any],
                 let azureConfig = config["AzureOpenAI"] as? [String: String],
                 let endpoint = azureConfig["Endpoint"],
                 let apiKey = azureConfig["APIKey"] {
                  print("✅ Azure config loaded successfully!")
                  print("Endpoint: \(endpoint)")
                  print("API Key: \(String(apiKey.prefix(10)))...")
              } else {
                  print("❌ Failed to load Azure configuration!")
              }
          }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
