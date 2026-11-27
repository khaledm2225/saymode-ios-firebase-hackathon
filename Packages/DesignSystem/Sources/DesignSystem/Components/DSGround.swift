import SwiftUI

/// The app background. Dark: three layers top to bottom, fine grain, a soft vignette, and a vertical tonal fade.
/// Light: flat cream. It sits behind everything, ignores safe areas and never scrolls.
/// With Increase Contrast on, the grain is left out, so text sits on a clean tonal fade.
public struct DSGround: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dsShowsGroundGrain) private var showsGrain

    public init() {}

    public var body: some View {
        ZStack {
            LinearGradient(colors: [.ds(.groundTop), .ds(.groundMid), .ds(.groundBottom)],
                           startPoint: .top, endPoint: .bottom)
            if colorScheme == .dark {
                // The vignette: clear in the middle, darker toward the edges.
                EllipticalGradient(stops: [
                    .init(color: .clear, location: DSMetrics.Ground.vignetteClearUntil),
                    .init(color: .ds(.vignette).opacity(DSMetrics.Ground.vignetteEdgeOpacity), location: 1)
                ])
                if showsGrain && contrast != .increased {
                    // The grain asset is 2x, so it tiles at its token size in points.
                    DSTexture.grain.image
                        .resizable(resizingMode: .tile)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

public extension EnvironmentValues {
    /// Whether the dark ground shows its grain texture. On by default.
    /// Turn it off where a check reads rendered pixels, such as Apple's accessibility audit,
    /// which can mistake the grain's light specks for text color.
    @Entry var dsShowsGroundGrain: Bool = true
}

public extension View {
    /// Puts the design system ground behind this view.
    func dsGround() -> some View {
        background { DSGround() }
    }
}
