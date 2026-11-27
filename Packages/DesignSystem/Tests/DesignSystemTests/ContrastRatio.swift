import UIKit

/// WCAG 2 contrast ratio between two colors, from 1 (no contrast) to 21 (black on white).
enum ContrastRatio {
    static func between(_ first: UIColor, _ second: UIColor) -> Double {
        let lighter = max(luminance(of: first), luminance(of: second))
        let darker = min(luminance(of: first), luminance(of: second))
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Relative luminance in the sRGB color space.
    private static func luminance(of color: UIColor) -> Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let linear = [red, green, blue].map { channel -> Double in
            let value = Double(channel)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
    }
}
