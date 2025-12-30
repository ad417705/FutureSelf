//
//  AzureConfig.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation

struct AzureConfig {
    let endpoint: String
    let apiKey: String
    let deploymentName: String

    static func load() -> AzureConfig? {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let azureConfig = config["AzureOpenAI"] as? [String: String],
              let endpoint = azureConfig["Endpoint"],
              let apiKey = azureConfig["APIKey"],
              let deploymentName = azureConfig["DeploymentName"] else {
            print("❌ Failed to load Azure configuration from Configuration.plist")
            return nil
        }

        print("✅ Azure config loaded: \(endpoint)")
        return AzureConfig(endpoint: endpoint, apiKey: apiKey, deploymentName: deploymentName)
    }
}
