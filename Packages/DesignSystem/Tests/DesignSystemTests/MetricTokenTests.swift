import XCTest
@testable import DesignSystem

final class MetricTokenTests: XCTestCase {
    func test_strokes_matchDesignTokensFile() throws {
        let file = try TokenFile()
        XCTAssertEqual(DSMetrics.Stroke.interactive, try file.number("stroke.interactive"))
        XCTAssertEqual(DSMetrics.Stroke.icon, try file.number("stroke.icon"))
    }

    func test_shadows_matchDesignTokensFile() throws {
        let file = try TokenFile()
        XCTAssertEqual(DSMetrics.Shadow.interactive, try file.number("shadow.interactive.x"))
        XCTAssertEqual(DSMetrics.Shadow.interactive, try file.number("shadow.interactive.y"))
        XCTAssertEqual(DSMetrics.Shadow.small, try file.number("shadow.small.x"))
        XCTAssertEqual(DSMetrics.Shadow.small, try file.number("shadow.small.y"))
        XCTAssertEqual(try file.number("shadow.interactive.blur"), 0)
        XCTAssertEqual(try file.number("shadow.small.blur"), 0)
    }

    func test_radii_matchDesignTokensFile() throws {
        let file = try TokenFile()
        XCTAssertEqual(DSMetrics.Radius.card, try file.number("radius.card"))
        XCTAssertEqual(DSMetrics.Radius.option, try file.number("radius.option"))
        XCTAssertEqual(DSMetrics.Radius.input, try file.number("radius.input"))
        XCTAssertEqual(DSMetrics.Radius.iconTile, try file.number("radius.iconTile"))
        XCTAssertEqual(try file.string("radius.button"), "capsule")
    }

    func test_sizes_matchDesignTokensFile() throws {
        let file = try TokenFile()
        XCTAssertEqual(DSMetrics.Size.minTouchTarget, try file.number("size.minTouchTarget"))
        XCTAssertEqual(DSMetrics.Size.primaryButtonHeight, try file.number("size.primaryButtonHeight"))
    }

    func test_minimumTouchTarget_meetsAppleMinimumOf44Points() {
        XCTAssertGreaterThanOrEqual(DSMetrics.Size.minTouchTarget, 44)
    }

    func test_groundLayers_matchDesignTokensFile() throws {
        let file = try TokenFile()
        XCTAssertEqual(DSMetrics.Ground.grainTileSize, try file.number("color.dark.ground.grain.tileSize"))
        XCTAssertEqual(DSMetrics.Ground.vignetteClearUntil, try file.number("color.dark.ground.vignette.clearUntil"))
        XCTAssertEqual(DSMetrics.Ground.vignetteEdgeOpacity, try file.number("color.dark.ground.vignette.edgeOpacity"))
    }

    func test_spacingScale_growsInOrder() {
        let scale = [DSMetrics.Spacing.xxs, DSMetrics.Spacing.xs, DSMetrics.Spacing.sm,
                     DSMetrics.Spacing.md, DSMetrics.Spacing.lg, DSMetrics.Spacing.xl]
        XCTAssertEqual(scale, scale.sorted())
        XCTAssertEqual(Set(scale).count, scale.count)
    }
}
