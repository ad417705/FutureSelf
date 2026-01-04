//  ImageFilterUtilities.swift
import UIKit
import CoreImage

struct ImageFilterUtilities {

    /// Apply degradation filters based on budget status
    static func applyStatusFilters(to imageData: Data, status: BudgetStatus) -> Data? {
        guard let uiImage = UIImage(data: imageData),
              let ciImage = CIImage(image: uiImage) else {
            return imageData
        }

        var outputImage = ciImage

        switch status {
        case .good:
            // No filters, return original
            return imageData

        case .warning:
            // Apply slight blur and desaturation
            if let blurFilter = CIFilter(name: "CIGaussianBlur") {
                blurFilter.setValue(outputImage, forKey: kCIInputImageKey)
                blurFilter.setValue(2.0, forKey: kCIInputRadiusKey)
                if let output = blurFilter.outputImage {
                    outputImage = output
                }
            }

            if let saturationFilter = CIFilter(name: "CIColorControls") {
                saturationFilter.setValue(outputImage, forKey: kCIInputImageKey)
                saturationFilter.setValue(0.7, forKey: kCIInputSaturationKey)
                if let output = saturationFilter.outputImage {
                    outputImage = output
                }
            }

        case .danger:
            // Apply stronger blur, heavy desaturation, and darkness
            if let blurFilter = CIFilter(name: "CIGaussianBlur") {
                blurFilter.setValue(outputImage, forKey: kCIInputImageKey)
                blurFilter.setValue(5.0, forKey: kCIInputRadiusKey)
                if let output = blurFilter.outputImage {
                    outputImage = output
                }
            }

            if let saturationFilter = CIFilter(name: "CIColorControls") {
                saturationFilter.setValue(outputImage, forKey: kCIInputImageKey)
                saturationFilter.setValue(0.3, forKey: kCIInputSaturationKey)
                saturationFilter.setValue(-0.3, forKey: kCIInputBrightnessKey)
                if let output = saturationFilter.outputImage {
                    outputImage = output
                }
            }
        }

        // Convert back to Data
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return imageData
        }

        let processedImage = UIImage(cgImage: cgImage)
        return processedImage.jpegData(compressionQuality: 0.9)
    }

    /// Generate placeholder image with gradient and icon
    static func generatePlaceholder(for goalType: GoalType, size: CGSize = CGSize(width: 600, height: 400)) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let ctx = context.cgContext

            // Get goal-specific colors
            let gradientColors = getGradientColors(for: goalType)

            // Draw radial gradient for more depth
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [gradientColors.0.cgColor, gradientColors.1.cgColor] as CFArray,
                locations: [0, 1]
            )!

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = max(size.width, size.height)

            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )

            // Add subtle texture overlay
            ctx.setBlendMode(.overlay)
            ctx.setAlpha(0.1)
            for _ in 0..<50 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let radius = CGFloat.random(in: 1...3)
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fillEllipse(in: CGRect(x: x, y: y, width: radius, height: radius))
            }

            ctx.setBlendMode(.normal)
            ctx.setAlpha(1.0)

            // Draw large semi-transparent icon in background
            let bgConfig = UIImage.SymbolConfiguration(pointSize: 280, weight: .ultraLight)
            if let bgIcon = UIImage(systemName: goalType.icon, withConfiguration: bgConfig) {
                ctx.setAlpha(0.15)
                let bgIconSize = bgIcon.size
                let bgOrigin = CGPoint(
                    x: (size.width - bgIconSize.width) / 2,
                    y: (size.height - bgIconSize.height) / 2
                )
                bgIcon.withTintColor(.white).draw(at: bgOrigin)
            }

            ctx.setAlpha(1.0)

            // Draw main icon in center
            let config = UIImage.SymbolConfiguration(pointSize: 180, weight: .medium)
            if let icon = UIImage(systemName: goalType.icon, withConfiguration: config) {
                let iconSize = icon.size
                let origin = CGPoint(
                    x: (size.width - iconSize.width) / 2,
                    y: (size.height - iconSize.height) / 2
                )

                // Add shadow for depth
                ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 10, color: UIColor.black.withAlphaComponent(0.3).cgColor)
                icon.withTintColor(.white).draw(at: origin)
            }

            // Add goal type text at bottom
            ctx.setShadow(offset: .zero, blur: 0)
            let text = goalType.displayName
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.white,
                .kern: 2.0
            ]
            let attributedText = NSAttributedString(string: text.uppercased(), attributes: attributes)
            let textSize = attributedText.size()
            let textOrigin = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: size.height - textSize.height - 30
            )

            // Text shadow
            ctx.setShadow(offset: CGSize(width: 0, height: 2), blur: 8, color: UIColor.black.withAlphaComponent(0.5).cgColor)
            attributedText.draw(at: textOrigin)
        }

        return image.jpegData(compressionQuality: 0.9)
    }

    /// Get gradient colors for each goal type
    private static func getGradientColors(for goalType: GoalType) -> (UIColor, UIColor) {
        switch goalType {
        case .travel:
            return (UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0),  // Sky blue
                    UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0))  // Sunset pink
        case .moveOut:
            return (UIColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 1.0),  // Green
                    UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0))  // Blue
        case .emergencyFund:
            return (UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0),  // Gold
                    UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0))  // Red
        case .debtFree:
            return (UIColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 1.0),  // Purple
                    UIColor(red: 0.7, green: 0.2, blue: 0.5, alpha: 1.0))  // Magenta
        case .education:
            return (UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0),  // Blue
                    UIColor(red: 0.5, green: 0.3, blue: 0.6, alpha: 1.0))  // Purple
        case .familySupport:
            return (UIColor(red: 0.9, green: 0.4, blue: 0.5, alpha: 1.0),  // Rose
                    UIColor(red: 0.8, green: 0.3, blue: 0.6, alpha: 1.0))  // Pink
        case .retirement:
            return (UIColor(red: 0.3, green: 0.6, blue: 0.7, alpha: 1.0),  // Teal
                    UIColor(red: 0.5, green: 0.4, blue: 0.7, alpha: 1.0))  // Purple-blue
        case .custom:
            return (UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0),  // Gray-blue
                    UIColor(red: 0.6, green: 0.4, blue: 0.7, alpha: 1.0))  // Purple-gray
        }
    }
}
