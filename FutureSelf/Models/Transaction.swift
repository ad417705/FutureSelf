//  Transaction.swift
import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let userId: String
    var amount: Decimal
    var description: String
    var category: TransactionCategory
    var date: Date
    
    init(id: String = UUID().uuidString, userId: String, amount: Decimal, description: String, category: TransactionCategory, date: Date = Date()) {
        self.id = id
        self.userId = userId
        self.amount = amount
        self.description = description
        self.category = category
        self.date = date
    }
}

enum TransactionCategory: String, Codable, CaseIterable {
    case housing, utilities, food, transportation, entertainment, income, other
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "tv.fill"
        case .income: return "dollarsign.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
