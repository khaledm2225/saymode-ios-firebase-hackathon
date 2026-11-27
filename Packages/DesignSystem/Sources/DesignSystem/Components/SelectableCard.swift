import SwiftUI

/// The state of a selectable card.
public enum SelectableCardState: Sendable {
    case unselected
    case selected
    /// Shown but not pickable, for example the language the user is already learning.
    case unavailable
}

/// How a selectable card arranges its content.
public enum SelectableCardLayout: Sendable {
    /// Leading accessory, text, then the indicator on one row. Language and level choices.
    /// At accessibility text sizes it stacks like a tile so the text has the full width.
    case row
    /// Accessory and indicator on top, text below. Goal choices in a grid.
    case tile
}

/// The indicator on the trailing side of a card.
enum SelectionIndicatorKind: Equatable {
    case none
    case empty
    case checked
}

/// The colors, shadow and indicator a card uses in a given state.
struct SelectableCardAppearance: Equatable {
    let fill: DSColor
    let line: DSColor
    let title: DSColor
    let subtitle: DSColor
    let indicator: SelectionIndicatorKind
    let castsShadow: Bool

    /// A disabled card looks unavailable in every state, so it never looks tappable.
    init(state: SelectableCardState, isEnabled: Bool = true) {
        switch isEnabled ? state : .unavailable {
        case .unselected:
            fill = .raised
            line = .line
            title = .text
            subtitle = .muted
            indicator = .empty
            castsShadow = true
        case .selected:
            fill = .sun
            line = .ink
            title = .ink
            subtitle = .ink
            indicator = .checked
            castsShadow = true
        case .unavailable:
            fill = .surface
            line = .edge
            title = .muted
            subtitle = .muted
            indicator = .none
            castsShadow = false
        }
    }
}

/// A tappable choice card: sun yellow with a check when selected, flat and shadowless when unavailable or disabled.
/// VoiceOver reads it as a button with the Selected trait when picked.
public struct SelectableCard<Leading: View>: View {
    private let title: Text
    private let subtitle: Text?
    private let state: SelectableCardState
    private let layout: SelectableCardLayout
    private let action: () -> Void
    private let leading: Leading

    public init(title: Text, subtitle: Text? = nil, state: SelectableCardState, layout: SelectableCardLayout = .row,
                action: @escaping () -> Void, @ViewBuilder leading: () -> Leading) {
        self.title = title
        self.subtitle = subtitle
        self.state = state
        self.layout = layout
        self.action = action
        self.leading = leading()
    }

    public var body: some View {
        Button(action: action) {
            SelectableCardContent(title: title, subtitle: subtitle, state: state, layout: layout, leading: leading)
        }
        .buttonStyle(SelectableCardButtonStyle(state: state))
        .disabled(state == .unavailable)
        .accessibilityAddTraits(state == .selected ? .isSelected : [])
    }
}

public extension SelectableCard where Leading == EmptyView {
    init(title: Text, subtitle: Text? = nil, state: SelectableCardState, layout: SelectableCardLayout = .row,
         action: @escaping () -> Void) {
        self.init(title: title, subtitle: subtitle, state: state, layout: layout, action: action) { EmptyView() }
    }
}

private struct SelectableCardContent<Leading: View>: View {
    let title: Text
    let subtitle: Text?
    let state: SelectableCardState
    let layout: SelectableCardLayout
    let leading: Leading
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var padding = DSMetrics.Spacing.md
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.sm

    private var stacksVertically: Bool {
        layout == .tile || dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        let look = SelectableCardAppearance(state: state, isEnabled: isEnabled)
        if stacksVertically {
            VStack(alignment: .leading, spacing: spacing) {
                HStack(alignment: .top, spacing: spacing) {
                    leading
                    Spacer(minLength: 0)
                    SelectionIndicator(kind: look.indicator)
                }
                SelectableCardText(title: title, subtitle: subtitle, look: look)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(padding)
            .frame(maxWidth: .infinity, minHeight: DSMetrics.Size.minTouchTarget, alignment: .topLeading)
        } else {
            HStack(spacing: spacing) {
                leading
                SelectableCardText(title: title, subtitle: subtitle, look: look)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SelectionIndicator(kind: look.indicator)
            }
            .padding(padding)
            .frame(maxWidth: .infinity, minHeight: DSMetrics.Size.minTouchTarget, alignment: .leading)
        }
    }
}

private struct SelectableCardText: View {
    let title: Text
    let subtitle: Text?
    let look: SelectableCardAppearance
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.xxs

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            title
                .dsFont(.heading)
                .foregroundStyle(.ds(look.title))
            if let subtitle {
                subtitle
                    .dsFont(.caption)
                    .foregroundStyle(.ds(look.subtitle))
            }
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SelectableCardButtonStyle: ButtonStyle {
    let state: SelectableCardState

    func makeBody(configuration: Configuration) -> some View {
        SelectableCardButtonBody(configuration: configuration, state: state)
    }
}

private struct SelectableCardButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let state: SelectableCardState
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let look = SelectableCardAppearance(state: state, isEnabled: isEnabled)
        let pressOffset = look.castsShadow && configuration.isPressed ? DSMetrics.Shadow.interactive : 0
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: DSMetrics.Radius.option))
            .modifier(StickerSurface(shape: RoundedRectangle(cornerRadius: DSMetrics.Radius.option),
                                     fill: look.fill, line: look.line, castsShadow: look.castsShadow,
                                     shadowOffset: DSMetrics.Shadow.interactive, pressOffset: pressOffset))
            .animation(.snappy(duration: 0.08), value: configuration.isPressed)
            .sensoryFeedback(.selection, trigger: configuration.isPressed) { _, isPressed in
                isPressed && look.castsShadow
            }
    }
}

/// The radio circle on an unselected card, or the check on a selected one.
struct SelectionIndicator: View {
    let kind: SelectionIndicatorKind
    @ScaledMetric(relativeTo: .body) private var size = DSMetrics.Size.selectionIndicator

    var body: some View {
        switch kind {
        case .none:
            EmptyView()
        case .empty:
            Circle()
                .fill(.ds(.groundBottom))
                .overlay { Circle().strokeBorder(.ds(.line), lineWidth: DSMetrics.Stroke.interactive) }
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        case .checked:
            Circle()
                .fill(.ds(.ink))
                .overlay {
                    DSIconView(.check, size: DSMetrics.Size.selectionCheck)
                        .foregroundStyle(.ds(.bubble))
                }
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        }
    }
}
