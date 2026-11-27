import SwiftUI
import UIKit
import XCTest
@testable import DesignSystem

@MainActor
final class TypographyTests: XCTestCase {
    override func setUp() async throws {
        DSFonts.registerIfNeeded()
    }

    func test_registration_makesEveryBundledFaceAvailable() {
        for face in DSFontFace.allCases {
            XCTAssertNotNil(UIFont(name: face.postScriptName, size: 17), "\(face.postScriptName) is not registered")
        }
    }

    func test_registration_canRunTwice_withoutFailing() {
        DSFonts.registerIfNeeded()
        DSFonts.registerIfNeeded()
        XCTAssertNotNil(UIFont(name: DSFontFace.displayExtraBold.postScriptName, size: 17))
    }

    func test_displayFace_isBricolageGrotesqueAtWeight800() throws {
        let font = try XCTUnwrap(UIFont(name: DSFontFace.displayExtraBold.postScriptName, size: 17))
        XCTAssertEqual(font.familyName, "Bricolage Grotesque")
        XCTAssertEqual(try weightAxisValue(of: font), 800, accuracy: 0.5)
    }

    func test_bodyFaces_arePlusJakartaSansAtTheirNamedWeights() throws {
        let expected: [(DSFontFace, Double)] = [(.bodyMedium, 500), (.bodySemiBold, 600), (.bodyBold, 700), (.bodyExtraBold, 800)]
        for (face, weight) in expected {
            let font = try XCTUnwrap(UIFont(name: face.postScriptName, size: 17))
            XCTAssertEqual(font.familyName, "Plus Jakarta Sans")
            XCTAssertEqual(try weightAxisValue(of: font), weight, accuracy: 0.5, "\(face)")
        }
    }

    func test_everyTextStyle_growsAtTheLargestAccessibilityTextSize() {
        for style in DSTextStyle.allCases {
            let regular = renderedHeight(of: style, at: .large)
            let largest = renderedHeight(of: style, at: .accessibility5)
            XCTAssertGreaterThan(largest, regular * 1.5, "\(style) does not follow Dynamic Type: \(regular) to \(largest)")
        }
    }

    func test_everyTextStyle_shrinksAtTheSmallestTextSize() {
        for style in DSTextStyle.allCases {
            XCTAssertLessThan(renderedHeight(of: style, at: .xSmall), renderedHeight(of: style, at: .large), "\(style)")
        }
    }

    private func renderedHeight(of style: DSTextStyle, at size: DynamicTypeSize) -> CGFloat {
        let host = UIHostingController(rootView: Text(verbatim: "Ag").dsFont(style).dynamicTypeSize(size))
        return host.sizeThatFits(in: CGSize(width: 1000, height: 1000)).height
    }

    func test_noTextStyle_isSmallerThanApplesMinimumOfElevenPoints() {
        for style in DSTextStyle.allCases {
            XCTAssertGreaterThanOrEqual(style.size, 11, "\(style)")
        }
    }

    func test_titles_useTheDisplayFace_andBodyStyles_usePlusJakartaSans() {
        XCTAssertEqual(DSTextStyle.display.face, .displayExtraBold)
        XCTAssertEqual(DSTextStyle.title.face, .displayExtraBold)
        for style in DSTextStyle.allCases where style != .display && style != .title {
            XCTAssertTrue(style.face.postScriptName.hasPrefix("PlusJakartaSans"), "\(style)")
        }
    }

    func test_textStyles_scaleRelativeToMatchingSystemStyles() {
        XCTAssertEqual(DSTextStyle.display.relativeTo, .largeTitle)
        XCTAssertEqual(DSTextStyle.title.relativeTo, .title)
        XCTAssertEqual(DSTextStyle.body.relativeTo, .body)
        XCTAssertEqual(DSTextStyle.button.relativeTo, .headline)
    }

    private func weightAxisValue(of font: UIFont) throws -> Double {
        let weightAxis: UInt32 = 0x77676874 // 'wght'
        let ctFont = font as CTFont
        if let variation = CTFontCopyVariation(ctFont) as? [NSNumber: NSNumber],
           let value = variation[NSNumber(value: weightAxis)] {
            return value.doubleValue
        }
        let axes = try XCTUnwrap(CTFontCopyVariationAxes(ctFont) as? [[String: Any]])
        let axis = try XCTUnwrap(axes.first { ($0[kCTFontVariationAxisIdentifierKey as String] as? NSNumber)?.uint32Value == weightAxis })
        return try XCTUnwrap(axis[kCTFontVariationAxisDefaultValueKey as String] as? NSNumber).doubleValue
    }
}
