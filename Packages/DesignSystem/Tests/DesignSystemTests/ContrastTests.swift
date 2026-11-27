import UIKit
import XCTest
@testable import DesignSystem

@MainActor
final class ContrastTests: XCTestCase {
    private let dark = UITraitCollection(userInterfaceStyle: .dark)
    private let light = UITraitCollection(userInterfaceStyle: .light)

    /// Pairs checked in design-tokens.json. The dark ground is measured on its lightest layer, groundTop.
    private var pairs: [(name: String, foreground: DSColor, background: DSColor, traits: UITraitCollection)] {
        [
            ("creamOnGround", .text, .groundTop, dark),
            ("mutedOnGround", .muted, .groundTop, dark),
            ("mutedOnSurface", .muted, .surface, dark),
            ("sunOnGround", .sun, .groundTop, dark),
            ("bubblegumOnGround", .bubblegum, .groundTop, dark),
            ("inkOnSun", .ink, .sun, dark),
            ("inkOnBubblegum", .ink, .bubblegum, dark),
            ("inkOnPopBlue", .ink, .popBlue, dark),
            ("mutedOnCreamLight", .muted, .groundTop, light)
        ]
    }

    func test_contrastRatios_matchDesignTokensFile() throws {
        let file = try TokenFile()
        for pair in pairs {
            let ratio = try contrast(pair.foreground, on: pair.background, traits: pair.traits)
            XCTAssertEqual(ratio, try file.number("contrast.\(pair.name)"), accuracy: 0.06, pair.name)
        }
    }

    func test_everyTextPair_passesWCAGLevelAA() throws {
        for pair in pairs {
            let ratio = try contrast(pair.foreground, on: pair.background, traits: pair.traits)
            XCTAssertGreaterThanOrEqual(ratio, 4.5, "\(pair.name) is below 4.5:1")
        }
    }

    func test_everyEnabledButtonLabel_passesWCAGLevelAA_onItsFill_inBothThemes() throws {
        for kind in StickerButtonKind.allCases {
            let look = StickerButtonAppearance(kind: kind, isEnabled: true)
            for traits in [dark, light] {
                let ratio = try contrast(look.label, on: look.fill, traits: traits)
                XCTAssertGreaterThanOrEqual(ratio, 4.5, "\(kind) label in \(traits.userInterfaceStyle == .dark ? "dark" : "light")")
            }
        }
    }

    func test_everySelectableCardText_passesWCAGLevelAA_onItsFill_inBothThemes() throws {
        for state in [SelectableCardState.unselected, .selected] {
            let look = SelectableCardAppearance(state: state)
            for traits in [dark, light] {
                let theme = traits.userInterfaceStyle == .dark ? "dark" : "light"
                XCTAssertGreaterThanOrEqual(try contrast(look.title, on: look.fill, traits: traits), 4.5, "\(state) title in \(theme)")
                XCTAssertGreaterThanOrEqual(try contrast(look.subtitle, on: look.fill, traits: traits), 4.5, "\(state) subtitle in \(theme)")
            }
        }
    }

    func test_backButtonIcon_passesWCAGLevelAA_onItsFill_inBothThemes() throws {
        let look = RoundStickerAppearance(isEnabled: true)
        for traits in [dark, light] {
            XCTAssertGreaterThanOrEqual(try contrast(look.label, on: look.fill, traits: traits), 4.5)
        }
    }

    func test_contrastRatio_ofBlackOnWhite_is21() {
        XCTAssertEqual(ContrastRatio.between(.black, .white), 21, accuracy: 0.001)
    }

    func test_contrastRatio_isTheSameInBothOrders() {
        XCTAssertEqual(ContrastRatio.between(.red, .white), ContrastRatio.between(.white, .red), accuracy: 0.0001)
    }

    private func contrast(_ foreground: DSColor, on background: DSColor, traits: UITraitCollection) throws -> Double {
        let front = try XCTUnwrap(foreground.uiColor).resolvedColor(with: traits)
        let back = try XCTUnwrap(background.uiColor).resolvedColor(with: traits)
        return ContrastRatio.between(front, back)
    }
}
