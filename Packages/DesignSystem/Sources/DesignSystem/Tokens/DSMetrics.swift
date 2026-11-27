import CoreGraphics

/// Every size in the design system. Values come from design-tokens.json; tests keep them in sync.
/// Views scale these base values with Dynamic Type through `@ScaledMetric`, so nothing on screen is a fixed size.
public enum DSMetrics {
    /// Line widths.
    public enum Stroke {
        /// Outline of buttons, cards and inputs.
        public static let interactive: CGFloat = 2.5
        /// Icon stroke at the 24 point canvas size.
        public static let icon: CGFloat = 2.2
        /// White sticker edge around speech tags and bubbles.
        public static let stickerEdge: CGFloat = 4
    }

    /// Hard offset shadows, no blur.
    public enum Shadow {
        /// Buttons and selectable cards. The element moves this far into its shadow when pressed.
        public static let interactive: CGFloat = 4
        /// Small elements such as the back button and icon tiles.
        public static let small: CGFloat = 3
    }

    /// Corner radii. Buttons are capsules.
    public enum Radius {
        public static let card: CGFloat = 24
        public static let option: CGFloat = 18
        public static let input: CGFloat = 16
        public static let iconTile: CGFloat = 16
    }

    /// Base sizes before Dynamic Type scaling.
    public enum Size {
        /// Apple's minimum hit target.
        public static let minTouchTarget: CGFloat = 44
        /// Primary button height at the default text size.
        public static let primaryButtonHeight: CGFloat = 56
        /// Icon size at the default text size.
        public static let icon: CGFloat = 24
        /// Selection indicator (radio and check).
        public static let selectionIndicator: CGFloat = 24
        /// The check mark inside a selected indicator.
        public static let selectionCheck: CGFloat = 14
        /// Icon tile on cards.
        public static let iconTile: CGFloat = 50
        /// Height of one progress segment.
        public static let progressSegment: CGFloat = 10
    }

    /// Spacing scale, smallest to largest.
    public enum Spacing {
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }

    /// The dark ground's layers.
    public enum Ground {
        /// The grain texture tiles at this size in points.
        public static let grainTileSize: CGFloat = 128
        /// The vignette stays clear until this fraction of the radius.
        public static let vignetteClearUntil: CGFloat = 0.55
        /// The vignette's opacity at the edges.
        public static let vignetteEdgeOpacity: CGFloat = 0.42
    }
}
