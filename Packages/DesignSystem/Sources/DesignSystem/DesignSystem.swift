// DesignSystem: the Jody and Pip design system for saymode.
// Tokens, fonts, icons drawn in code, and SwiftUI components. No app logic.
// It uses SwiftUI, plus CoreText to register the bundled fonts. No UIKit: the tests bring their own.
import Foundation

/// The bundle that holds the package's assets and fonts. Tests reach it through `@testable import`,
/// because inside the test target `Bundle.module` means the test bundle.
enum DSResources {
    static var bundle: Bundle { .module }
}
