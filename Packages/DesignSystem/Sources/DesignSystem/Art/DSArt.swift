import SwiftUI

/// Juno and Pip art from the kit. Every image has a white sticker border, so it works on both themes.
public enum DSCharacterPose: String, CaseIterable, Sendable {
    case hey
    case nailedIt
    case oops
    case thinking
    case welcomeHero
    case junoFace

    var assetName: String {
        switch self {
        case .hey: "character-hey"
        case .nailedIt: "character-nailed-it"
        case .oops: "character-oops"
        case .thinking: "character-thinking"
        case .welcomeHero: "character-welcome-hero"
        case .junoFace: "character-juno-face"
        }
    }

    /// What VoiceOver reads for the art.
    public var accessibilityLabel: LocalizedStringResource {
        switch self {
        case .hey: LocalizedStringResource("Juno and Pip waving", bundle: .atURL(Bundle.module.bundleURL))
        case .nailedIt: LocalizedStringResource("Juno cheering and Pip jumping", bundle: .atURL(Bundle.module.bundleURL))
        case .oops: LocalizedStringResource("Juno laughing and Pip covering its mouth", bundle: .atURL(Bundle.module.bundleURL))
        case .thinking: LocalizedStringResource("Juno thinking and Pip with a question mark", bundle: .atURL(Bundle.module.bundleURL))
        case .welcomeHero: LocalizedStringResource("Juno waving and Pip jumping, with greetings in five languages", bundle: .atURL(Bundle.module.bundleURL))
        case .junoFace: LocalizedStringResource("Juno", bundle: .atURL(Bundle.module.bundleURL))
        }
    }
}

/// The 8 avatar stickers the user can pick.
public enum DSAvatar: Int, CaseIterable, Sendable, Identifiable {
    case avatar1 = 1, avatar2, avatar3, avatar4, avatar5, avatar6, avatar7, avatar8

    public var id: Int { rawValue }

    var assetName: String { "avatar-\(rawValue)" }

    /// What VoiceOver reads for the avatar.
    public var accessibilityLabel: LocalizedStringResource {
        LocalizedStringResource("Avatar \(rawValue)", bundle: .atURL(Bundle.module.bundleURL))
    }
}

/// Textures for the ground.
public enum DSTexture: String, CaseIterable, Sendable {
    /// Seamless cream grain, tiled on the dark ground.
    case grain

    var assetName: String { "texture-grain" }

    var image: Image {
        Image(decorative: assetName, bundle: .module)
    }
}

/// Shows a character pose at a size set by its container. The art keeps its aspect ratio and never stretches.
public struct DSCharacterView: View {
    private let pose: DSCharacterPose

    public init(_ pose: DSCharacterPose) {
        self.pose = pose
    }

    public var body: some View {
        Image(pose.assetName, bundle: .module, label: Text(pose.accessibilityLabel))
            .resizable()
            .scaledToFit()
    }
}

/// Shows an avatar as a round sticker at a size set by its container.
/// The art is square, so the view cuts it into a circle and draws the sticker edge in code:
/// an ink outline on the art, a white sticker ring, and an ink line around the ring.
/// It casts no shadow: only a tappable avatar does, through the button style that wraps it.
public struct DSAvatarView: View {
    private let avatar: DSAvatar

    public init(_ avatar: DSAvatar) {
        self.avatar = avatar
    }

    public var body: some View {
        Image(avatar.assetName, bundle: .module, label: Text(avatar.accessibilityLabel))
            .resizable()
            .scaledToFit()
            .clipShape(.circle)
            .overlay {
                Circle().strokeBorder(.ds(.ink), lineWidth: DSMetrics.Stroke.interactive)
            }
            .padding(DSMetrics.Stroke.stickerEdge)
            .background {
                Circle().fill(.ds(.bubble))
            }
            .overlay {
                Circle().strokeBorder(.ds(.ink), lineWidth: DSMetrics.Stroke.interactive)
            }
    }
}
