import CoreGraphics
import XCTest
@testable import DesignSystem

final class SVGPathParserTests: XCTestCase {
    func test_absoluteMoveAndLine_buildAStraightSegment() throws {
        let bounds = try SVGPathParser.parse("M5 12L19 12").boundingBoxOfPath
        XCTAssertEqual(bounds.minX, 5, accuracy: 0.001)
        XCTAssertEqual(bounds.maxX, 19, accuracy: 0.001)
        XCTAssertEqual(bounds.midY, 12, accuracy: 0.001)
    }

    func test_relativeCommands_areOffsetFromTheCurrentPoint() throws {
        let bounds = try SVGPathParser.parse("M5 12h14").boundingBoxOfPath
        XCTAssertEqual(bounds.maxX, 19, accuracy: 0.001)
    }

    func test_horizontalAndVerticalLines_moveOneAxisOnly() throws {
        let bounds = try SVGPathParser.parse("M4 4H20V20").boundingBoxOfPath
        XCTAssertEqual(bounds, CGRect(x: 4, y: 4, width: 16, height: 16))
    }

    func test_implicitRepeat_afterMove_isTreatedAsLine() throws {
        let bounds = try SVGPathParser.parse("M3 3 21 21").boundingBoxOfPath
        XCTAssertEqual(bounds, CGRect(x: 3, y: 3, width: 18, height: 18))
    }

    func test_compactNumbers_withoutSeparators_areSplitCorrectly() throws {
        // "M13 6l6 6-6 6" relies on the minus sign starting a new number.
        let bounds = try SVGPathParser.parse("M13 6l6 6-6 6").boundingBoxOfPath
        XCTAssertEqual(bounds, CGRect(x: 13, y: 6, width: 6, height: 12))
    }

    func test_decimalNumbers_withoutLeadingZeroSeparators_areSplitCorrectly() throws {
        // ".5.5" is two numbers: 0.5 and 0.5.
        let bounds = try SVGPathParser.parse("M1 1l.5.5").boundingBoxOfPath
        XCTAssertEqual(bounds.maxX, 1.5, accuracy: 0.001)
        XCTAssertEqual(bounds.maxY, 1.5, accuracy: 0.001)
    }

    func test_cubicCurve_staysInsideItsControlHull() throws {
        let bounds = try SVGPathParser.parse("M12 3c3 3 3 15 0 18").boundingBoxOfPath
        XCTAssertEqual(bounds.minY, 3, accuracy: 0.001)
        XCTAssertEqual(bounds.maxY, 21, accuracy: 0.001)
        XCTAssertLessThanOrEqual(bounds.maxX, 15)
        XCTAssertGreaterThan(bounds.maxX, 12)
    }

    func test_smoothCubic_reflectsThePreviousControlPoint() throws {
        // With the reflection, the second curve dips to -7.5. Without it, it would only reach about -4.4.
        let bounds = try SVGPathParser.parse("M0 0c0 10 10 10 10 0s10-10 10 0").boundingBoxOfPath
        XCTAssertEqual(bounds.minX, 0, accuracy: 0.01)
        XCTAssertEqual(bounds.minY, -7.5, accuracy: 0.01)
        XCTAssertEqual(bounds.width, 20, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 15, accuracy: 0.01)
    }

    func test_arc_halfCircle_bulgesUpAndReachesItsEndPoint() throws {
        // The lock icon's shackle: a half circle of radius 4 from (8 11) over the top to (16 11).
        let bounds = try SVGPathParser.parse("M8 11a4 4 0 0 1 8 0").boundingBoxOfPath
        XCTAssertEqual(bounds.minX, 8, accuracy: 0.01)
        XCTAssertEqual(bounds.maxX, 16, accuracy: 0.01)
        XCTAssertEqual(bounds.minY, 7, accuracy: 0.05)
    }

    func test_closePath_returnsToTheStartPoint() throws {
        let path = try SVGPathParser.parse("M8 5v14l11-7z")
        XCTAssertEqual(path.boundingBoxOfPath, CGRect(x: 8, y: 5, width: 11, height: 14))
        XCTAssertFalse(path.isEmpty)
    }

    func test_unknownCommand_throws() {
        XCTAssertThrowsError(try SVGPathParser.parse("M1 1 K2 2"))
    }

    func test_emptyString_throws() {
        XCTAssertThrowsError(try SVGPathParser.parse(""))
    }
}
