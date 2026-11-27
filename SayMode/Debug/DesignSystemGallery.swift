#if DEBUG
import DesignSystem
import SwiftUI

/// Debug-only screen that shows every DesignSystem component, so UI tests can audit them
/// at every Dynamic Type size and in both themes. It never ships in a Release build.
struct DesignSystemGallery: View {
    @ScaledMetric(relativeTo: .body) private var padding = DSMetrics.Spacing.lg
    @ScaledMetric(relativeTo: .body) private var sectionSpacing = DSMetrics.Spacing.xl

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                GalleryButtons()
                GalleryCards()
                GalleryGoalTiles()
                GalleryProgressAndTags()
                GalleryIcons()
                GalleryArt()
                Text(verbatim: "End of gallery")
                    .dsFont(.caption)
                    .foregroundStyle(.ds(.muted))
                    .accessibilityIdentifier("gallery.end")
            }
            .padding(padding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .dsGround()
    }
}

private struct GallerySectionTitle: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .dsFont(.title)
            .foregroundStyle(.ds(.text))
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("gallery.section.\(text)")
    }
}

private struct GalleryButtons: View {
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.md

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GallerySectionTitle(text: "Buttons")
            DSBackButton {}
                .accessibilityIdentifier("gallery.back")
            Button {} label: { Text(verbatim: "Continue") }
                .buttonStyle(.sticker(.primary))
                .accessibilityIdentifier("gallery.primary")
            Button {} label: { Text(verbatim: "Not now") }
                .buttonStyle(.sticker(.secondary))
                .accessibilityIdentifier("gallery.secondary")
            Button {} label: { Text(verbatim: "Continue") }
                .buttonStyle(.sticker(.primary))
                .disabled(true)
                .accessibilityIdentifier("gallery.disabled")
        }
    }
}

private struct GalleryCards: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.md

    /// Side by side at standard sizes. Stacked at accessibility sizes, so long words never break.
    private var iconAndText: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GallerySectionTitle(text: "Cards")
            SelectableCard(title: Text(verbatim: "English"), subtitle: Text(verbatim: "English"), state: .selected) {}
                .accessibilityIdentifier("gallery.card.english")
            SelectableCard(title: Text(verbatim: "Español"), subtitle: Text(verbatim: "You’re learning this one."),
                           state: .unavailable) {}
                .accessibilityIdentifier("gallery.card.espanol")
            SelectableCard(title: Text(verbatim: "Intermediate"), subtitle: Text(verbatim: "I can have simple talks."),
                           state: .unselected) {} leading: {
                DSIconTile(.progress, fill: .sun)
            }
            .accessibilityIdentifier("gallery.card.intermediate")
            DSStaticCard {
                iconAndText {
                    DSIconTile(.mic, fill: .bubblegum)
                    VStack(alignment: .leading) {
                        Text(verbatim: "Microphone").dsFont(.heading).foregroundStyle(.ds(.text))
                        Text(verbatim: "So Juno can hear you.").dsFont(.caption).foregroundStyle(.ds(.muted))
                    }
                }
            }
            .accessibilityIdentifier("gallery.card.microphone")
        }
    }
}

private struct GalleryGoalTiles: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.md

    private struct Goal: Hashable {
        let icon: DSIcon
        let fill: DSColor
        let title: String
        let subtitle: String
        let isSelected: Bool
    }

    private let goals: [Goal] = [
        Goal(icon: .work, fill: .bubblegum, title: "Work", subtitle: "Meetings and emails", isSelected: false),
        Goal(icon: .travel, fill: .popBlue, title: "Travel", subtitle: "Trips and new places", isSelected: true),
        Goal(icon: .interview, fill: .sun, title: "Interviews", subtitle: "Job interviews", isSelected: false),
        Goal(icon: .everyday, fill: .popBlue, title: "Everyday talk", subtitle: "Friends and daily life", isSelected: true)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GallerySectionTitle(text: "Goal tiles")
            GalleryGrid(goals, columns: AdaptiveColumns.count(preferred: 2, for: dynamicTypeSize), spacing: spacing) { goal in
                SelectableCard(title: Text(verbatim: goal.title), subtitle: Text(verbatim: goal.subtitle),
                               state: goal.isSelected ? .selected : .unselected, layout: .tile) {} leading: {
                    DSIconTile(goal.icon, fill: goal.fill, castsShadow: true)
                }
                .accessibilityIdentifier("gallery.tile.\(goal.title)")
            }
        }
    }
}

private struct GalleryProgressAndTags: View {
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.md

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GallerySectionTitle(text: "Progress and tags")
            SegmentedProgressBar(current: 3, total: 5)
                .accessibilityIdentifier("gallery.progress")
            DSSpeechTag(Text(verbatim: "No wrong answers here."))
                .accessibilityIdentifier("gallery.tag")
        }
    }
}

private struct GalleryIcons: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.md

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GallerySectionTitle(text: "Icons")
            GalleryGrid(DSIcon.allCases, columns: AdaptiveColumns.count(preferred: 6, for: dynamicTypeSize), spacing: spacing) { icon in
                DSIconView(icon)
                    .foregroundStyle(.ds(.text))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "All 27 icons"))
        }
    }
}

private struct GalleryArt: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var spacing = DSMetrics.Spacing.md

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GallerySectionTitle(text: "Characters and avatars")
            GalleryGrid(DSCharacterPose.allCases, columns: AdaptiveColumns.count(preferred: 3, for: dynamicTypeSize), spacing: spacing) { pose in
                DSCharacterView(pose)
            }
            GalleryGrid(DSAvatar.allCases, columns: AdaptiveColumns.count(preferred: 4, for: dynamicTypeSize), spacing: spacing) { avatar in
                DSAvatarView(avatar)
            }
        }
    }
}

/// A plain, non lazy grid. The gallery is small, so every row is measured up front
/// and the scroll height stays exact when the text size changes.
private struct GalleryGrid<Item: Hashable, Cell: View>: View {
    private let rows: [[Item]]
    private let spacing: CGFloat
    private let cell: (Item) -> Cell

    init(_ items: [Item], columns: Int, spacing: CGFloat, @ViewBuilder cell: @escaping (Item) -> Cell) {
        let width = max(1, columns)
        self.rows = stride(from: 0, to: items.count, by: width).map { Array(items[$0..<min($0 + width, items.count)]) }
        self.spacing = spacing
        self.cell = cell
    }

    var body: some View {
        Grid(alignment: .top, horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(rows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { item in
                        cell(item)
                    }
                }
            }
        }
    }
}

#Preview("Dark") {
    DesignSystemGallery().preferredColorScheme(.dark)
}

#Preview("Light, largest text") {
    DesignSystemGallery().preferredColorScheme(.light).dynamicTypeSize(.accessibility5)
}
#endif
