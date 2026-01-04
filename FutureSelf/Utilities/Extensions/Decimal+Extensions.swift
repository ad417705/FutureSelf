//  Decimal+Extensions.swift
import Foundation

extension Decimal {
    var asDouble: Double {
        Double(truncating: self as NSNumber)
    }
}
