import CoreText
import Foundation

/// The named font faces bundled in the package. Both files are variable fonts (SIL Open Font License 1.1);
/// each face is a named instance inside them, so weights are exact, with no synthesized bold.
public enum DSFontFace: String, CaseIterable, Sendable {
    /// Bricolage Grotesque, weight 800, display optical size. Titles.
    case displayExtraBold
    /// Plus Jakarta Sans, weight 500. Body text.
    case bodyMedium
    /// Plus Jakarta Sans, weight 600.
    case bodySemiBold
    /// Plus Jakarta Sans, weight 700.
    case bodyBold
    /// Plus Jakarta Sans, weight 800. Buttons and card titles.
    case bodyExtraBold

    /// The PostScript name Core Text gives this named instance.
    public var postScriptName: String {
        switch self {
        case .displayExtraBold: "BricolageGrotesque-96ptExtraBold"
        case .bodyMedium: "PlusJakartaSans-Regular_Medium"
        case .bodySemiBold: "PlusJakartaSans-Regular_SemiBold"
        case .bodyBold: "PlusJakartaSans-Regular_Bold"
        case .bodyExtraBold: "PlusJakartaSans-Regular_ExtraBold"
        }
    }
}

/// Registers the bundled fonts with Core Text for this process.
/// A Swift package has no Info.plist, so the fonts are registered at runtime instead of through UIAppFonts.
public enum DSFonts {
    /// Registers the fonts once. Safe to call many times and from any thread.
    public static func registerIfNeeded() {
        _ = registration
    }

    private static let fontFiles = ["BricolageGrotesque", "PlusJakartaSans"]

    /// Runs once: Swift initializes static properties lazily and thread safely.
    private static let registration: Void = {
        for file in fontFiles {
            guard let url = Bundle.module.url(forResource: file, withExtension: "ttf") else {
                assertionFailure("Missing bundled font \(file).ttf")
                continue
            }
            var error: Unmanaged<CFError>?
            let registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            if !registered, let failure = error?.takeRetainedValue(),
               CFErrorGetCode(failure) != CTFontManagerError.alreadyRegistered.rawValue {
                assertionFailure("Could not register \(file).ttf: \(failure)")
            }
        }
    }()
}
