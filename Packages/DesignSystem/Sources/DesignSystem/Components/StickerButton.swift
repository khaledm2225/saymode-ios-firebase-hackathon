import SwiftUI

/// The button kinds in the design system.
public enum StickerButtonKind: CaseIterable, Sendable {
    /// The main action: bubblegum fill.
    case primary
    /// A secondary action: raised fill with the theme's line color.
    case secondary
}

/// The colors and shadow a sticker button uses in a given state.
struct StickerButtonAppearance: Equatable {
    let fill: DSColor
    let line: DSColor
    let label: DSColor
    let castsShadow: Bool

    init(kind: StickerButtonKind, isEnabled: Bool) {
        guard isEnabled else {
            // No shadow: it must not look tappable.
            fill = .raised
            line = .edge
            label = .muted
            castsShadow = false
            return
        }
        switch kind {
        case .primary:
            fill = .bubblegum
            line = .ink
            label = .ink
        case .secondary:
            fill = .raised
            line = .line
            label = .text
        }
        castsShadow = true
    }

    /// Pressing moves the button into its shadow. A button without a shadow stays still.
    func pressOffset(isPressed: Bool) -> CGFloat {
        castsShadow && isPressed ? DSMetrics.Shadow.interactive : 0
    }
}

/// A full-width capsule button with a hard shadow. It grows with Dynamic Type and its label can wrap.
public struct StickerButtonStyle: ButtonStyle {
    private let kind: StickerButtonKind

    public init(_ kind: StickerButtonKind = .primary) {
        self.kind = kind
    }

    public func makeBody(configuration: Configuration) -> some View {
        StickerButtonBody(configuration: configuration, kind: kind)
    }
}

public extension ButtonStyle where Self == StickerButtonStyle {
    /// The design system's sticker button, for example `.buttonStyle(.sticker(.secondary))`.
    static func sticker(_ kind: StickerButtonKind = .primary) -> StickerButtonStyle {
        StickerButtonStyle(kind)
    }
}

private struct StickerButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: StickerButtonKind
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric(relativeTo: .headline) private var minHeight = DSMetrics.Size.primaryButtonHeight
    @ScaledMetric(relativeTo: .headline) private var horizontalPadding = DSMetrics.Spacing.lg
    @ScaledMetric(relativeTo: .headline) private var verticalPadding = DSMetrics.Spacing.sm

    var body: some View {
        let look = StickerButtonAppearance(kind: kind, isEnabled: isEnabled)
        configuration.label
            .dsFont(.button)
            .multilineTextAlignment(.center)
            .foregroundStyle(.ds(look.label))
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .contentShape(Capsule())
            .modifier(StickerSurface(shape: Capsule(), fill: look.fill, line: look.line,
                                     castsShadow: look.castsShadow, shadowOffset: DSMetrics.Shadow.interactive,
                                     pressOffset: look.pressOffset(isPressed: configuration.isPressed)))
            .animation(.snappy(duration: 0.08), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, isPressed in
                isPressed && isEnabled
            }
    }
}
