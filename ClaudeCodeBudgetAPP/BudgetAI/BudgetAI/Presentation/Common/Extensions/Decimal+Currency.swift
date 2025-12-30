//
//  Decimal+Currency.swift
//  BudgetAI
//
//  Created by Claude on 12/25/25.
//

import Foundation

extension Decimal {
    func toCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
}

extension String {
    func toDecimal() -> Decimal? {
        // Remove currency symbols and commas
        let cleaned = self
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)

        return Decimal(string: cleaned)
    }
}
