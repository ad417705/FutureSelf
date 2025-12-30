//
//  HapticManager.swift
//  BudgetAI
//
//  Created by Claude on 12/26/25.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func lightImpact() {
        impact(style: .light)
    }

    func mediumImpact() {
        impact(style: .medium)
    }

    func heavyImpact() {
        impact(style: .heavy)
    }

    // MARK: - Notification Feedback

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func success() {
        notification(type: .success)
    }

    func warning() {
        notification(type: .warning)
    }

    func error() {
        notification(type: .error)
    }

    // MARK: - Selection Feedback

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
