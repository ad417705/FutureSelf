//
//  BudgetStatus.swift
//  FutureSelf
//

import Foundation
import SwiftUI

enum BudgetStatus: String, Codable {
    case good
    case warning
    case danger

    var displayName: String {
        switch self {
        case .good: return "On Track"
        case .warning: return "Watch It"
        case .danger: return "Needs Attention"
        }
    }

    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .danger: return .red
        }
    }

    var imageModifier: String {
        switch self {
        case .good: return "bright, clear, complete, inspiring"
        case .warning: return "slightly faded, minor imperfections, cloudy"
        case .danger: return "damaged, stormy, broken, incomplete"
        }
    }
}
