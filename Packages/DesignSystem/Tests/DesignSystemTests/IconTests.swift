import CoreGraphics
import XCTest
@testable import DesignSystem

final class IconTests: XCTestCase {
    /// The file names in the kit's assets/icons folder.
    private let kitIconNames: Set<String> = [
        "arrow", "back", "check", "cloud", "everyday", "eye", "fix", "globe", "goal", "home",
        "interview", "lesson", "lock", "mail", "mic", "notebook", "phone", "play", "profile",
        "progress", "search", "speaker", "talk", "travel", "word", "work", "x"
    ]

    func test_iconSet_hasExactlyTheKitsTwentySevenIcons() {
        XCTAssertEqual(DSIcon.allCases.count, 27)
        XCTAssertEqual(Set(DSIcon.allCases.map(\.kitName)), kitIconNames)
    }

    func test_everyIcon_buildsANonEmptyPath() throws {
        for icon in DSIcon.allCases {
            let path = try icon.cgPath()
            XCTAssertFalse(path.isEmpty, "\(icon) is empty")
        }
    }

    func test_everyIcon_staysInsideItsTwentyFourPointCanvas() throws {
        let canvas = CGRect(x: 0, y: 0, width: DSIcon.canvasSize, height: DSIcon.canvasSize)
        for icon in DSIcon.allCases {
            let bounds = try icon.cgPath().boundingBoxOfPath
            XCTAssertTrue(canvas.contains(bounds), "\(icon) spills outside the canvas: \(bounds)")
        }
    }

    func test_onlyPlay_isFilled_everyOtherIconIsStroked() {
        for icon in DSIcon.allCases {
            XCTAssertEqual(icon.isFilled, icon == .play, "\(icon)")
        }
    }

    func test_strokeWidth_scalesWithIconSize_andMatchesTokenAtTwentyFourPoints() {
        XCTAssertEqual(DSIcon.strokeWidth(forSize: 24), DSMetrics.Stroke.icon, accuracy: 0.0001)
        XCTAssertEqual(DSIcon.strokeWidth(forSize: 48), DSMetrics.Stroke.icon * 2, accuracy: 0.0001)
    }

    func test_canvasSize_isTwentyFour() {
        XCTAssertEqual(DSIcon.canvasSize, 24)
    }
}
