import UIKit
import XCTest
@testable import DesignSystem

@MainActor
final class ColorTokenTests: XCTestCase {
    private let dark = UITraitCollection(userInterfaceStyle: .dark)
    private let light = UITraitCollection(userInterfaceStyle: .light)

    /// Each color token and the design-tokens.json paths for its dark and light values.
    private let expectations: [(token: DSColor, dark: String, light: String)] = [
        (.groundTop, "color.dark.ground.top", "color.light.background"),
        (.groundMid, "color.dark.ground.mid", "color.light.background"),
        (.groundBottom, "color.dark.ground.bottom", "color.light.background"),
        (.surface, "color.dark.surface", "color.light.surface"),
        (.raised, "color.dark.raised", "color.light.raised"),
        (.edge, "color.dark.edge", "color.light.edge"),
        (.field, "color.dark.field", "color.light.field"),
        (.text, "color.dark.text", "color.light.text"),
        (.line, "color.dark.line", "color.light.line"),
        (.shadow, "color.dark.shadow", "color.light.shadow"),
        (.muted, "color.dark.muted", "color.light.muted"),
        (.sunTint, "color.dark.sunTint", "color.light.sunTint"),
        (.sun, "color.accent.sun", "color.accent.sun"),
        (.bubblegum, "color.accent.bubblegum", "color.accent.bubblegum"),
        (.popBlue, "color.accent.popBlue", "color.accent.popBlue"),
        (.ink, "color.accent.ink", "color.accent.ink"),
        (.vignette, "color.dark.ground.vignette.color", "color.dark.ground.vignette.color")
    ]

    func test_everyColorToken_matchesDesignTokensFile_inDarkTheme() throws {
        let file = try TokenFile()
        for expectation in expectations {
            let resolved = try resolve(expectation.token, in: dark)
            XCTAssertEqual(resolved, try file.string(expectation.dark).uppercased(), "\(expectation.token) in dark")
        }
    }

    func test_everyColorToken_matchesDesignTokensFile_inLightTheme() throws {
        let file = try TokenFile()
        for expectation in expectations {
            let resolved = try resolve(expectation.token, in: light)
            XCTAssertEqual(resolved, try file.string(expectation.light).uppercased(), "\(expectation.token) in light")
        }
    }

    func test_speechBubble_staysWhiteInBothThemes() throws {
        XCTAssertEqual(try resolve(.bubble, in: dark), "#FFFFFF")
        XCTAssertEqual(try resolve(.bubble, in: light), "#FFFFFF")
    }

    func test_everyColorToken_isCovered() {
        let tested = Set(expectations.map(\.token)).union([.bubble])
        XCTAssertEqual(tested, Set(DSColor.allCases))
    }

    private func resolve(_ token: DSColor, in traits: UITraitCollection) throws -> String {
        let color = try XCTUnwrap(token.uiColor, "No color asset for \(token)")
        return color.resolvedColor(with: traits).hexString
    }
}
