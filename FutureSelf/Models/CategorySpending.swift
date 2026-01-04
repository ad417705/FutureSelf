//  CategorySpending.swift
import Foundation
import SwiftUI

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: TransactionCategory
    let amount: Decimal
    let percentage: Double
}
