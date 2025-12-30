//
//  DesignSystem.swift
//  BudgetAI
//
//  Created by Claude on 12/26/25.
//  Mercedes-Benz inspired premium design system
//

import SwiftUI

struct DesignSystem {

    // MARK: - Colors (Mercedes-Benz Premium Palette)

    struct Colors {
        // Dark theme backgrounds
        static let primaryBackground = Color(hex: "#0a0a0a")
        static let secondaryBackground = Color(hex: "#1a1a1a")
        static let cardBackground = Color(hex: "#1f1f1f")
        static let elevatedBackground = Color(hex: "#2d2d2d")

        // Text colors
        static let primaryText = Color(hex: "#ffffff")
        static let secondaryText = Color(hex: "#b0b0b0")
        static let tertiaryText = Color(hex: "#808080")

        // Accent colors - Premium Gold Palette
        static let premiumSilver = Color(hex: "#c8c8c8")
        static let platinum = Color(hex: "#e5e4e2")
        static let luxuryGold = Color(hex: "#d4af37")
        static let champagneGold = Color(hex: "#f7e7ce")
        static let roseGold = Color(hex: "#b76e79")
        static let darkGold = Color(hex: "#a8853c")

        // Status colors
        static let success = Color(hex: "#00d084")
        static let warning = Color(hex: "#ffb800")
        static let error = Color(hex: "#ff3b30")
        static let income = Color(hex: "#d4af37") // Gold for income

        // Gradients
        static let premiumGradient = LinearGradient(
            colors: [Color(hex: "#1a1a1a"), Color(hex: "#0a0a0a")],
            startPoint: .top,
            endPoint: .bottom
        )

        static let accentGradient = LinearGradient(
            colors: [Color(hex: "#d4af37"), Color(hex: "#f7e7ce")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let darkGoldGradient = LinearGradient(
            colors: [Color(hex: "#a8853c"), Color(hex: "#d4af37")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Typography

    struct Typography {
        // Headers
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

        // Body
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)

        // Small
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let pill: CGFloat = 999
    }

    // MARK: - Shadows

    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)

        struct Shadow {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
    }

    // MARK: - Animations

    struct Animations {
        static let quick = Animation.easeOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let premium = Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0.2)
        static let luxurious = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.5)

        // Staggered animation for lists
        static func staggered(index: Int, total: Int = 10) -> Animation {
            let delay = Double(index) * 0.05
            return .spring(response: 0.4, dampingFraction: 0.8).delay(delay)
        }
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    func premiumCard() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.large)
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }

    func premiumButton(style: PremiumButtonStyle = .primary) -> some View {
        self
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(style == .primary ? .white : DesignSystem.Colors.primaryText)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                Group {
                    if style == .primary {
                        DesignSystem.Colors.accentGradient
                    } else {
                        LinearGradient(
                            colors: [DesignSystem.Colors.elevatedBackground],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

enum PremiumButtonStyle {
    case primary
    case secondary
}
