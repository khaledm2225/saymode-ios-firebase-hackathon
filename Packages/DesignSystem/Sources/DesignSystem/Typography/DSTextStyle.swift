import SwiftUI

/// The type scale. Every style follows Dynamic Type: its size is the size at the default text setting (Large),
/// and it scales relative to the matching system text style, so titles grow less than body text.
public enum DSTextStyle: CaseIterable, Sendable {
    /// Hero titles, such as the Welcome screen.
    case display
    /// Screen titles.
    case title
    /// Card titles and section headings.
    case heading
    /// Body text.
    case body
    /// Emphasized body text.
    case bodyStrong
    /// Button labels.
    case button
    /// Supporting text under titles.
    case callout
    /// Emphasized supporting text, such as speech tags.
    case calloutStrong
    /// Small supporting text.
    case caption
    /// Small uppercase labels, such as "YOUR PLAN".
    case label

    /// The bundled face this style uses.
    public var face: DSFontFace {
        switch self {
        case .display, .title: .displayExtraBold
        case .heading, .button, .label: .bodyExtraBold
        case .body, .callout: .bodyMedium
        case .bodyStrong, .calloutStrong: .bodyBold
        case .caption: .bodySemiBold
        }
    }

    /// The point size at the default Dynamic Type setting.
    public var size: CGFloat {
        switch self {
        case .display: 32
        case .title: 28
        case .heading: 18
        case .body, .bodyStrong, .button: 17
        case .callout, .calloutStrong: 15
        case .caption: 13
        case .label: 12
        }
    }

    /// The system text style this style scales with.
    public var relativeTo: Font.TextStyle {
        switch self {
        case .display: .largeTitle
        case .title: .title
        case .heading: .title3
        case .body, .bodyStrong: .body
        case .button: .headline
        case .callout, .calloutStrong: .subheadline
        case .caption: .footnote
        case .label: .caption
        }
    }

    /// The SwiftUI font for this style. It follows Dynamic Type, never a fixed size.
    public var font: Font {
        DSFonts.registerIfNeeded()
        return .custom(face.postScriptName, size: size, relativeTo: relativeTo)
    }
}

public extension View {
    /// Applies a design system text style.
    func dsFont(_ style: DSTextStyle) -> some View {
        font(style.font)
    }
}
