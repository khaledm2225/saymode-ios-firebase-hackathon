import SwiftUI

/// Column counts that follow Apple's Dynamic Type guidance:
/// at accessibility text sizes, reduce the number of columns so text has room to grow.
public enum AdaptiveColumns {
    public static func count(preferred: Int, for size: DynamicTypeSize) -> Int {
        let safePreferred = max(1, preferred)
        return size.isAccessibilitySize ? 1 : safePreferred
    }

    /// Flexible grid columns for a `LazyVGrid`, using `count(preferred:for:)`.
    public static func gridItems(preferred: Int, for size: DynamicTypeSize, spacing: CGFloat) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing, alignment: .top), count: count(preferred: preferred, for: size))
    }
}
