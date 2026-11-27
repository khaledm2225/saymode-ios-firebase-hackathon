import SwiftUI

/// A static card: surface fill with an edge outline and no shadow, because it is not tappable.
public struct DSStaticCard<Content: View>: View {
    private let content: Content
    @ScaledMetric(relativeTo: .body) private var padding = DSMetrics.Spacing.md

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: DSMetrics.Radius.card).fill(.ds(.surface))
            }
            .overlay {
                RoundedRectangle(cornerRadius: DSMetrics.Radius.card)
                    .strokeBorder(.ds(.edge), lineWidth: DSMetrics.Stroke.interactive)
            }
    }
}

/// A rounded square tile in an accent color with an ink icon, used on goal and permission cards.
public struct DSIconTile: View {
    private let icon: DSIcon
    private let fill: DSColor
    private let castsShadow: Bool
    @ScaledMetric(relativeTo: .body) private var side = DSMetrics.Size.iconTile

    public init(_ icon: DSIcon, fill: DSColor, castsShadow: Bool = false) {
        self.icon = icon
        self.fill = fill
        self.castsShadow = castsShadow
    }

    public var body: some View {
        DSIconView(icon)
            .foregroundStyle(.ds(.ink))
            .frame(width: side, height: side)
            .modifier(StickerSurface(shape: RoundedRectangle(cornerRadius: DSMetrics.Radius.iconTile),
                                     fill: fill, line: .ink, castsShadow: castsShadow,
                                     shadowOffset: DSMetrics.Shadow.small, pressOffset: 0))
            .accessibilityHidden(true)
    }
}
