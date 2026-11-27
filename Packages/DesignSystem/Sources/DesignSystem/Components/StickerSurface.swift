import SwiftUI

/// The sticker look shared by every tappable element: a flat fill, an outline,
/// and a hard offset shadow with no blur. If it has a shadow, you can tap it.
struct StickerSurface<Outline: InsettableShape>: ViewModifier {
    let shape: Outline
    let fill: DSColor
    let line: DSColor
    let castsShadow: Bool
    let shadowOffset: CGFloat
    /// How far the element has moved into its shadow (0 when not pressed).
    let pressOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .background { shape.fill(.ds(fill)) }
            .overlay { shape.strokeBorder(.ds(line), lineWidth: DSMetrics.Stroke.interactive) }
            .offset(x: pressOffset, y: pressOffset)
            .background {
                shape
                    .fill(.ds(.shadow))
                    .offset(x: shadowOffset, y: shadowOffset)
                    .opacity(castsShadow ? 1 : 0)
            }
            // Keep room for the shadow so a parent never clips it.
            .padding(.trailing, shadowOffset)
            .padding(.bottom, shadowOffset)
    }
}
