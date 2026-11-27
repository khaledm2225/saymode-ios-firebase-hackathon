#if DEBUG
import SwiftUI

/// Debug-only launch options that UI tests pass through the launch environment.
/// They pick a screen, a text size, an appearance and whether the ground shows its grain,
/// so tests can check every Dynamic Type size and both themes.
struct DebugLaunchOptions {
    enum Screen: String {
        case gallery
    }

    static let screenKey = "SAYMODE_SCREEN"
    static let dynamicTypeKey = "SAYMODE_DYNAMIC_TYPE"
    static let appearanceKey = "SAYMODE_APPEARANCE"
    static let grainKey = "SAYMODE_GRAIN"

    let screen: Screen
    let dynamicTypeSize: DynamicTypeSize?
    let colorScheme: ColorScheme?
    /// False when a test asks for the ground without its grain ("off").
    let showsGroundGrain: Bool

    /// Reads the options from the process environment. Nil when no debug screen was asked for.
    static func current(from environment: [String: String] = ProcessInfo.processInfo.environment) -> DebugLaunchOptions? {
        guard let rawScreen = environment[screenKey], let screen = Screen(rawValue: rawScreen) else { return nil }
        return DebugLaunchOptions(screen: screen,
                                  dynamicTypeSize: environment[dynamicTypeKey].flatMap(dynamicTypeSize(named:)),
                                  colorScheme: environment[appearanceKey].flatMap(colorScheme(named:)),
                                  showsGroundGrain: environment[grainKey] != "off")
    }

    private static func dynamicTypeSize(named name: String) -> DynamicTypeSize? {
        switch name {
        case "xSmall": .xSmall
        case "small": .small
        case "medium": .medium
        case "large": .large
        case "xLarge": .xLarge
        case "xxLarge": .xxLarge
        case "xxxLarge": .xxxLarge
        case "accessibility1": .accessibility1
        case "accessibility2": .accessibility2
        case "accessibility3": .accessibility3
        case "accessibility4": .accessibility4
        case "accessibility5": .accessibility5
        default: nil
        }
    }

    private static func colorScheme(named name: String) -> ColorScheme? {
        switch name {
        case "dark": .dark
        case "light": .light
        default: nil
        }
    }
}
#endif
