import SwiftUI

/// Which segments of a step progress bar are filled.
struct ProgressSegments: Equatable {
    let current: Int
    let total: Int

    init(current: Int, total: Int) {
        let safeTotal = max(1, total)
        self.total = safeTotal
        self.current = min(max(0, current), safeTotal)
    }

    var filled: [Bool] {
        (1...total).map { $0 <= current }
    }

    /// What VoiceOver reads as the value, for example "Step 2 of 5".
    var valueText: LocalizedStringResource {
        LocalizedStringResource("Step \(current) of \(total)", bundle: .atURL(Bundle.module.bundleURL))
    }
}

/// The onboarding progress bar: one capsule per step, filled up to the current step, with a "2/5" label.
public struct SegmentedProgressBar: View {
    private let segments: ProgressSegments
    @ScaledMetric(relativeTo: .caption) private var segmentHeight = DSMetrics.Size.progressSegment
    @ScaledMetric(relativeTo: .caption) private var spacing = DSMetrics.Spacing.xs

    public init(current: Int, total: Int) {
        segments = ProgressSegments(current: current, total: total)
    }

    public var body: some View {
        HStack(spacing: spacing) {
            HStack(spacing: spacing / 2) {
                ForEach(Array(segments.filled.enumerated()), id: \.offset) { _, isFilled in
                    Capsule()
                        .fill(.ds(isFilled ? .bubblegum : .raised))
                        .overlay {
                            Capsule().strokeBorder(.ds(isFilled ? .ink : .edge), lineWidth: DSMetrics.Stroke.interactive)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: segmentHeight)
                }
            }
            Text(verbatim: "\(segments.current)/\(segments.total)")
                .dsFont(.label)
                .foregroundStyle(.ds(.text))
                .monospacedDigit()
        }
        // VoiceOver and the accessibility audit see a native progress indicator, which is not a control,
        // so it reads as progress and is never treated as something to tap.
        .accessibilityRepresentation {
            ProgressView(value: Double(segments.current), total: Double(segments.total)) {
                Text("Progress", bundle: .module, comment: "VoiceOver label for the onboarding step progress bar.")
            } currentValueLabel: {
                Text(segments.valueText)
            }
        }
    }
}
