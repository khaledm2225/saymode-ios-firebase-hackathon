import SwiftUI

/// Every color in the Jody and Pip design system.
/// Each token is an asset catalog color with a light (Any) and a dark appearance, so SwiftUI switches themes by itself.
public enum DSColor: String, CaseIterable, Sendable {
    /// Ground fade, top layer. Dark: #211C18. Light: cream.
    case groundTop
    /// Ground fade, middle layer.
    case groundMid
    /// Ground fade, bottom layer.
    case groundBottom
    /// Static cards.
    case surface
    /// Inputs, secondary buttons, choices not selected.
    case raised
    /// Outline of static cards and dividers. Never text.
    case edge
    /// Outline of text inputs.
    case field
    /// Main text.
    case text
    /// Lines on dark fills (cream) or light fills (ink).
    case line
    /// Hard shadows: cream on dark, ink on light.
    case shadow
    /// Secondary text.
    case muted
    /// Background of the "Jody fixed it" card.
    case sunTint
    /// Hero shapes and the selected state.
    case sun
    /// Main action buttons.
    case bubblegum
    /// Voice and secondary actions. A fill only on dark, never text.
    case popBlue
    /// Text and lines on accent fills.
    case ink
    /// Speech bubbles and tags. White in both themes.
    case bubble
    /// The dark ground's vignette, black in design-tokens.json. Opacity comes from DSMetrics.Ground.
    case vignette

    /// The SwiftUI color for this token.
    public var color: Color {
        Color(rawValue, bundle: .module)
    }
}

public extension ShapeStyle where Self == Color {
    /// A design system color, for example `.foregroundStyle(.ds(.text))`.
    static func ds(_ token: DSColor) -> Color {
        token.color
    }
}
