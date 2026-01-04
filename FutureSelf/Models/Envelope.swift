//  Envelope.swift
import Foundation
import SwiftUI

struct Envelope: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    var name: String
    var budgetAmount: Decimal
    var spentAmount: Decimal
    var iconName: String
    var colorHex: String
    var isEssential: Bool
    
    init(id: String = UUID().uuidString, userId: String, name: String, budgetAmount: Decimal, spentAmount: Decimal = 0, iconName: String = "circle.fill", colorHex: String = "#007AFF", isEssential: Bool = false) {
        self.id = id
        self.userId = userId
        self.name = name
        self.budgetAmount = budgetAmount
        self.spentAmount = spentAmount
        self.iconName = iconName
        self.colorHex = colorHex
        self.isEssential = isEssential
    }
    
    var remaining: Decimal { budgetAmount - spentAmount }
    var percentUsed: Double {
        guard budgetAmount > 0 else { return 0 }
        return Double(truncating: (spentAmount / budgetAmount) as NSNumber)
    }
    var status: BudgetStatus {
        let pct = percentUsed
        if pct >= 1.0 { return .danger }
        if pct >= 0.8 { return .warning }
        return .good
    }
    var color: Color { Color(hex: colorHex) ?? .blue }
}
