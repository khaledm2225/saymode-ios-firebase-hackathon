import SwiftUI
import UIKit
import XCTest
@testable import DesignSystem

final class StickerButtonAppearanceTests: XCTestCase {
    func test_primary_isBubblegumWithInkLineAndInkLabel() {
        let look = StickerButtonAppearance(kind: .primary, isEnabled: true)
        XCTAssertEqual(look.fill, .bubblegum)
        XCTAssertEqual(look.line, .ink)
        XCTAssertEqual(look.label, .ink)
        XCTAssertTrue(look.castsShadow)
    }

    func test_secondary_isRaisedWithThemeLine() {
        let look = StickerButtonAppearance(kind: .secondary, isEnabled: true)
        XCTAssertEqual(look.fill, .raised)
        XCTAssertEqual(look.line, .line)
        XCTAssertEqual(look.label, .text)
        XCTAssertTrue(look.castsShadow)
    }

    func test_buttonKinds_arePrimaryAndSecondaryOnly() {
        XCTAssertEqual(StickerButtonKind.allCases, [.primary, .secondary])
    }

    func test_disabled_hasNoShadow_soItDoesNotLookTappable() {
        for kind in StickerButtonKind.allCases {
            let look = StickerButtonAppearance(kind: kind, isEnabled: false)
            XCTAssertFalse(look.castsShadow, "\(kind)")
            XCTAssertEqual(look.fill, .raised)
            XCTAssertEqual(look.line, .edge)
            XCTAssertEqual(look.label, .muted)
        }
    }

    func test_pressing_movesTheButtonIntoItsShadow() {
        let look = StickerButtonAppearance(kind: .primary, isEnabled: true)
        XCTAssertEqual(look.pressOffset(isPressed: true), DSMetrics.Shadow.interactive)
        XCTAssertEqual(look.pressOffset(isPressed: false), 0)
    }

    func test_pressing_aDisabledButton_doesNotMoveIt() {
        let look = StickerButtonAppearance(kind: .primary, isEnabled: false)
        XCTAssertEqual(look.pressOffset(isPressed: true), 0)
    }
}

final class SelectableCardAppearanceTests: XCTestCase {
    func test_unselected_isRaisedWithThemeLineAndEmptyIndicator() {
        let look = SelectableCardAppearance(state: .unselected)
        XCTAssertEqual(look.fill, .raised)
        XCTAssertEqual(look.line, .line)
        XCTAssertEqual(look.title, .text)
        XCTAssertEqual(look.subtitle, .muted)
        XCTAssertEqual(look.indicator, .empty)
        XCTAssertTrue(look.castsShadow)
    }

    func test_selected_isSunWithInkTextAndCheck() {
        let look = SelectableCardAppearance(state: .selected)
        XCTAssertEqual(look.fill, .sun)
        XCTAssertEqual(look.line, .ink)
        XCTAssertEqual(look.title, .ink)
        XCTAssertEqual(look.subtitle, .ink)
        XCTAssertEqual(look.indicator, .checked)
        XCTAssertTrue(look.castsShadow)
    }

    func test_unavailable_isFlatSurfaceWithNoShadowAndNoIndicator() {
        let look = SelectableCardAppearance(state: .unavailable)
        XCTAssertEqual(look.fill, .surface)
        XCTAssertEqual(look.line, .edge)
        XCTAssertEqual(look.title, .muted)
        XCTAssertEqual(look.indicator, .none)
        XCTAssertFalse(look.castsShadow)
    }

    func test_disabledCard_looksUnavailable_inEveryState_soItDoesNotLookTappable() {
        let unavailable = SelectableCardAppearance(state: .unavailable)
        for state in [SelectableCardState.unselected, .selected, .unavailable] {
            XCTAssertEqual(SelectableCardAppearance(state: state, isEnabled: false), unavailable, "\(state)")
        }
    }

    func test_enabledByDefault() {
        XCTAssertEqual(SelectableCardAppearance(state: .selected), SelectableCardAppearance(state: .selected, isEnabled: true))
    }
}

final class RoundStickerAppearanceTests: XCTestCase {
    func test_enabled_isRaisedWithThemeLineAndSmallShadow() {
        let look = RoundStickerAppearance(isEnabled: true)
        XCTAssertEqual(look.fill, .raised)
        XCTAssertEqual(look.line, .line)
        XCTAssertEqual(look.label, .text)
        XCTAssertTrue(look.castsShadow)
        XCTAssertEqual(look.pressOffset(isPressed: true), DSMetrics.Shadow.small)
    }

    func test_disabled_hasNoShadowAndDoesNotMove() {
        let look = RoundStickerAppearance(isEnabled: false)
        XCTAssertEqual(look.line, .edge)
        XCTAssertEqual(look.label, .muted)
        XCTAssertFalse(look.castsShadow)
        XCTAssertEqual(look.pressOffset(isPressed: true), 0)
    }

    func test_hitDiameter_neverDropsBelowAppleMinimum_atAnyTextSize() {
        let categories: [UIContentSizeCategory] = [.extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge,
                                                   .extraExtraExtraLarge, .accessibilityMedium, .accessibilityExtraExtraExtraLarge]
        for category in categories {
            let scaled = UIFontMetrics(forTextStyle: .body).scaledValue(
                for: DSMetrics.Size.minTouchTarget,
                compatibleWith: UITraitCollection(preferredContentSizeCategory: category))
            XCTAssertGreaterThanOrEqual(RoundStickerButtonStyle.hitDiameter(scaled: scaled), 44, "\(category.rawValue)")
        }
    }

    func test_hitDiameter_growsWithLargerText() {
        XCTAssertEqual(RoundStickerButtonStyle.hitDiameter(scaled: 60), 60)
    }
}

final class ProgressSegmentsTests: XCTestCase {
    func test_step3Of5_fillsTheFirstThreeSegments() {
        XCTAssertEqual(ProgressSegments(current: 3, total: 5).filled, [true, true, true, false, false])
    }

    func test_currentAboveTotal_isClampedToTotal() {
        XCTAssertEqual(ProgressSegments(current: 9, total: 5).filled, [true, true, true, true, true])
    }

    func test_currentBelowZero_isClampedToZero() {
        XCTAssertEqual(ProgressSegments(current: -2, total: 3).filled, [false, false, false])
    }

    func test_totalBelowOne_becomesOneSegment() {
        XCTAssertEqual(ProgressSegments(current: 0, total: 0).filled, [false])
    }

    func test_valueText_readsStepNOfTotal() {
        XCTAssertEqual(String(localized: ProgressSegments(current: 2, total: 5).valueText), "Step 2 of 5")
    }
}

final class AdaptiveColumnsTests: XCTestCase {
    func test_standardTextSizes_keepThePreferredColumnCount() {
        for size in DynamicTypeSize.allCases where !size.isAccessibilitySize {
            XCTAssertEqual(AdaptiveColumns.count(preferred: 2, for: size), 2, "\(size)")
        }
    }

    func test_accessibilityTextSizes_dropToOneColumn() {
        for size in DynamicTypeSize.allCases where size.isAccessibilitySize {
            XCTAssertEqual(AdaptiveColumns.count(preferred: 2, for: size), 1, "\(size)")
        }
    }

    func test_preferredBelowOne_isTreatedAsOne() {
        XCTAssertEqual(AdaptiveColumns.count(preferred: 0, for: .large), 1)
    }
}

@MainActor
final class ArtAssetTests: XCTestCase {
    func test_everyCharacterPose_isBundled() {
        for pose in DSCharacterPose.allCases {
            XCTAssertNotNil(pose.uiImage, "\(pose)")
        }
    }

    /// The avatar view cuts each image into a circle, so the art must be square and sharp
    /// even when the avatar fills the width of the screen at the largest text sizes.
    func test_everyAvatar_isSquareAndAtLeast1024Pixels() throws {
        for avatar in DSAvatar.allCases {
            let image = try XCTUnwrap(avatar.uiImage, "\(avatar)")
            let pixelWidth = image.size.width * image.scale
            let pixelHeight = image.size.height * image.scale
            XCTAssertEqual(pixelWidth, pixelHeight, "\(avatar) is not square")
            XCTAssertGreaterThanOrEqual(pixelWidth, 1024, "\(avatar) is too small to stay sharp")
        }
    }

    func test_eightAvatars_areBundled() {
        XCTAssertEqual(DSAvatar.allCases.count, 8)
        for avatar in DSAvatar.allCases {
            XCTAssertNotNil(avatar.uiImage, "\(avatar)")
        }
    }

    func test_grainTexture_isBundled_atTwiceItsTileSize() throws {
        let grain = try XCTUnwrap(DSTexture.grain.uiImage)
        XCTAssertEqual(grain.size.width, DSMetrics.Ground.grainTileSize, accuracy: 0.5)
    }
}
