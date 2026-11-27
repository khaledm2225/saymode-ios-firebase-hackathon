import CoreGraphics
import SwiftUI

/// The kit's 27 icons, drawn in code from their SVG source on a 24 point canvas with a 2.2 point stroke.
/// The app never uses SF Symbols.
public enum DSIcon: String, CaseIterable, Sendable {
    case arrow, back, check, cloud, everyday, eye, fix, globe, goal, home
    case interview, lesson, lock, mail, mic, notebook, phone, play, profile
    case progress, search, speaker, talk, travel, word, work, x

    /// The icon's file name in the kit's assets/icons folder.
    public var kitName: String { rawValue }

    /// The icons are drawn on a square canvas of this size.
    public static let canvasSize: CGFloat = 24

    /// The stroke width at a given icon size, keeping the kit's 2.2 point stroke proportional.
    public static func strokeWidth(forSize size: CGFloat) -> CGFloat {
        DSMetrics.Stroke.icon * size / canvasSize
    }

    /// Only the play icon is a filled shape; the rest are strokes.
    public var isFilled: Bool { self == .play }

    /// The icon's outline on its 24 point canvas.
    func cgPath() throws -> CGPath {
        let path = CGMutablePath()
        for element in elements {
            switch element {
            case .path(let data):
                path.addPath(try SVGPathParser.parse(data))
            case .circle(let centerX, let centerY, let radius):
                path.addEllipse(in: CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2))
            case .roundedRect(let x, let y, let width, let height, let radius):
                path.addRoundedRect(in: CGRect(x: x, y: y, width: width, height: height), cornerWidth: radius, cornerHeight: radius)
            }
        }
        return path
    }

    private enum Element {
        case path(String)
        case circle(CGFloat, CGFloat, CGFloat)
        case roundedRect(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
    }

    /// Copied from the kit's SVG files.
    private var elements: [Element] {
        switch self {
        case .arrow: [.path("M5 12h14M13 6l6 6-6 6")]
        case .back: [.path("M19 12H5M11 6l-6 6 6 6")]
        case .check: [.path("M5 12.5l4.5 4.5L19 7.5")]
        case .cloud: [.path("M7 18h11a4 4 0 0 0 0-8 6 6 0 0 0-11.5-1.5A4.5 4.5 0 0 0 7 18z")]
        case .everyday: [.path("M4 4h10a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H8.5L5 15v-3H4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1z"),
                         .path("M18 9h2a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1h-1v3l-4-3h-4a1 1 0 0 1-1-1v-1")]
        case .eye: [.path("M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"), .circle(12, 12, 3)]
        case .fix: [.path("M4 20l4-1L19 8l-3-3L5 16z"), .path("M14 7l3 3")]
        case .globe: [.circle(12, 12, 9), .path("M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18")]
        case .goal: [.circle(12, 12, 9), .circle(12, 12, 5), .circle(12, 12, 1.2)]
        case .home: [.path("M4 11.5 12 5l8 6.5V20a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1z")]
        case .interview: [.circle(9, 9, 3.5), .path("M3 20c1-3.5 3.5-5 6-5s5 1.5 6 5"), .path("M15 3h6v4.5h-3.5L15 10z")]
        case .lesson: [.roundedRect(4, 5, 16, 15, 2.5), .path("M4 10h16M9 3v4M15 3v4")]
        case .lock: [.roundedRect(5, 11, 14, 10, 2.5), .path("M8 11V8a4 4 0 0 1 8 0v3")]
        case .mail: [.roundedRect(3, 5, 18, 14, 2.5), .path("m3.5 7 8.5 6 8.5-6")]
        case .mic: [.roundedRect(9, 3, 6, 11, 3), .path("M5 11a7 7 0 0 0 14 0M12 18v3")]
        case .notebook: [.path("M6 3h11a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"), .path("M8 8h6M8 12h6")]
        case .phone: [.roundedRect(6, 2, 12, 20, 3), .path("M11 18h2")]
        case .play: [.path("M8 5v14l11-7z")]
        case .profile: [.circle(12, 8, 4), .path("M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6")]
        case .progress: [.path("M5 20v-6M12 20V6M19 20v-10")]
        case .search: [.circle(10.5, 10.5, 6.5), .path("M15.5 15.5 20 20")]
        case .speaker: [.path("M4 9v6h4l5 4V5L8 9H4z"), .path("M16.5 8.5a5 5 0 0 1 0 7")]
        case .talk: [.path("M5 5h14a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-7l-5 4v-4H5a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2z")]
        case .travel: [.path("M21 3 3 10.5l7 2.5 2.5 7z"), .path("M10 13 21 3")]
        case .word: [.circle(10.5, 10.5, 6.5), .path("M15.5 15.5 20 20M8 12.5l2.5-5 2.5 5M8.8 11h3.4")]
        case .work: [.roundedRect(3, 7, 18, 13, 2.5), .path("M9 7V5h6v2M3 12.5h18")]
        case .x: [.path("M6 6l12 12M18 6 6 18")]
        }
    }
}

/// The icon's outline as a SwiftUI shape, scaled from its 24 point canvas to any rectangle.
struct DSIconShape: Shape {
    let icon: DSIcon

    func path(in rect: CGRect) -> Path {
        guard let outline = try? icon.cgPath() else { return Path() }
        let scale = min(rect.width, rect.height) / DSIcon.canvasSize
        let transform = CGAffineTransform(translationX: rect.minX, y: rect.minY).scaledBy(x: scale, y: scale)
        return Path(outline).applying(transform)
    }
}

/// Draws a design system icon. Its size scales with Dynamic Type, and the stroke scales with it.
/// It takes the current foreground style, so color it with `.foregroundStyle(.ds(.ink))`.
public struct DSIconView: View {
    private let icon: DSIcon
    private let label: LocalizedStringResource?
    @ScaledMetric private var size: CGFloat

    /// - Parameters:
    ///   - icon: The icon to draw.
    ///   - size: The size at the default text setting. Defaults to the icon token size.
    ///   - textStyle: The text style the size scales with.
    ///   - label: A VoiceOver label. Leave it nil when the icon sits next to text that says the same thing.
    public init(_ icon: DSIcon, size: CGFloat = DSMetrics.Size.icon, relativeTo textStyle: Font.TextStyle = .body,
                label: LocalizedStringResource? = nil) {
        self.icon = icon
        self.label = label
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
    }

    public var body: some View {
        DSIconGlyph(icon: icon, size: size)
            .frame(width: size, height: size)
            .accessibilityHidden(label == nil)
            .accessibilityLabel(label.map { Text($0) } ?? Text(verbatim: ""))
    }
}

private struct DSIconGlyph: View {
    let icon: DSIcon
    let size: CGFloat

    var body: some View {
        if icon.isFilled {
            DSIconShape(icon: icon).fill()
        } else {
            DSIconShape(icon: icon)
                .stroke(style: StrokeStyle(lineWidth: DSIcon.strokeWidth(forSize: size), lineCap: .round, lineJoin: .round))
        }
    }
}
