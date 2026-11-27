import SwiftUI

/// The round back button with a small hard shadow. Never smaller than Apple's 44 point hit target.
public struct DSBackButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            DSIconView(.back)
        }
        .buttonStyle(RoundStickerButtonStyle())
        .accessibilityLabel(Text("Back", bundle: .module, comment: "VoiceOver label for the back button."))
    }
}

/// The colors and shadow a round sticker button uses. Disabled: no shadow, so it does not look tappable.
struct RoundStickerAppearance: Equatable {
    let fill: DSColor
    let line: DSColor
    let label: DSColor
    let castsShadow: Bool

    init(isEnabled: Bool) {
        fill = .raised
        line = isEnabled ? .line : .edge
        label = isEnabled ? .text : .muted
        castsShadow = isEnabled
    }

    func pressOffset(isPressed: Bool) -> CGFloat {
        castsShadow && isPressed ? DSMetrics.Shadow.small : 0
    }
}

/// A circle with a raised fill, the theme's line and a small shadow that the button presses into.
struct RoundStickerButtonStyle: ButtonStyle {
    /// The circle grows with Dynamic Type but never drops below Apple's minimum hit target.
    nonisolated static func hitDiameter(scaled: CGFloat) -> CGFloat {
        max(scaled, DSMetrics.Size.minTouchTarget)
    }

    func makeBody(configuration: Configuration) -> some View {
        RoundStickerButtonBody(configuration: configuration)
    }
}

private struct RoundStickerButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric(relativeTo: .body) private var scaledDiameter = DSMetrics.Size.minTouchTarget

    var body: some View {
        let look = RoundStickerAppearance(isEnabled: isEnabled)
        let diameter = RoundStickerButtonStyle.hitDiameter(scaled: scaledDiameter)
        configuration.label
            .foregroundStyle(.ds(look.label))
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .modifier(StickerSurface(shape: Circle(), fill: look.fill, line: look.line, castsShadow: look.castsShadow,
                                     shadowOffset: DSMetrics.Shadow.small,
                                     pressOffset: look.pressOffset(isPressed: configuration.isPressed)))
            .animation(.snappy(duration: 0.08), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, isPressed in
                isPressed && look.castsShadow
            }
    }
}
