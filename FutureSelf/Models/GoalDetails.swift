//  GoalDetails.swift
import Foundation

struct GoalDetails: Codable {
    var specificItem: String?          // e.g., "2024 Tesla Model 3"
    var location: String?              // e.g., "Paris, France"
    var color: String?                 // e.g., "midnight blue"
    var additionalDetails: [String: String]  // Flexible key-value pairs

    init(specificItem: String? = nil, location: String? = nil, color: String? = nil, additionalDetails: [String: String] = [:]) {
        self.specificItem = specificItem
        self.location = location
        self.color = color
        self.additionalDetails = additionalDetails
    }
}
