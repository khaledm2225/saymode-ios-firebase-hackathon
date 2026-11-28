import SwiftUI

/// A speech tag next to Jody: white with ink text and outline, and a white sticker edge, in both themes.
/// It is static (no shadow), and its text wraps as the text size grows.
public struct DSSpeechTag: View {
    private let text: Text
    @ScaledMetric(relativeTo: .subheadline) private var horizontalPadding = DSMetrics.Spacing.md
    @ScaledMetric(relativeTo: .subheadline) private var verticalPadding = DSMetrics.Spacing.sm

    public init(_ text: Text) {
        self.text = text
    }

    public var body: some View {
        text
            .dsFont(.calloutStrong)
            .foregroundStyle(.ds(.ink))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background {
                RoundedRectangle(cornerRadius: DSMetrics.Radius.input).fill(.ds(.bubble))
            }
            .overlay {
                RoundedRectangle(cornerRadius: DSMetrics.Radius.input)
                    .strokeBorder(.ds(.ink), lineWidth: DSMetrics.Stroke.interactive)
            }
            .padding(DSMetrics.Stroke.stickerEdge)
            .background {
                RoundedRectangle(cornerRadius: DSMetrics.Radius.input + DSMetrics.Stroke.stickerEdge).fill(.ds(.bubble))
            }
    }
}
