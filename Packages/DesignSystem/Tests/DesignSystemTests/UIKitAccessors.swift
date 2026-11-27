import UIKit
@testable import DesignSystem

// UIKit views of the design system's assets, for tests only.
// The shipped package stays SwiftUI; the tests use UIKit to resolve colors and read image sizes.

extension DSColor {
    var uiColor: UIColor? {
        UIColor(named: rawValue, in: DSResources.bundle, compatibleWith: nil)
    }
}

extension DSCharacterPose {
    var uiImage: UIImage? {
        UIImage(named: assetName, in: DSResources.bundle, with: nil)
    }
}

extension DSAvatar {
    var uiImage: UIImage? {
        UIImage(named: assetName, in: DSResources.bundle, with: nil)
    }
}

extension DSTexture {
    var uiImage: UIImage? {
        UIImage(named: assetName, in: DSResources.bundle, with: nil)
    }
}
