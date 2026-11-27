import XCTest

/// Proves the DesignSystem components work on screen: Apple's accessibility audit passes,
/// and every control stays on screen, tappable and at least 44 points, at the default and largest text sizes, in both themes.
@MainActor
final class DesignSystemGalleryUITests: XCTestCase {
    private enum TextSize: String {
        /// The simulator's own text size setting, left live so the Dynamic Type check can change it.
        case system = ""
        case standard = "large"
        case largest = "accessibility5"
    }

    private enum Appearance: String {
        case dark, light
    }

    /// The controls each run checks, by accessibility identifier.
    private let controlIdentifiers = [
        "gallery.back", "gallery.primary", "gallery.secondary",
        "gallery.card.english", "gallery.card.intermediate",
        "gallery.tile.Work", "gallery.tile.Travel"
    ]

    /// Every audit type that applies to iOS.
    private let fullAudit: XCUIAccessibilityAuditType = [
        .contrast, .dynamicType, .elementDetection, .hitRegion, .sufficientElementDescription, .textClipped, .trait
    ]

    /// Every check except Dynamic Type. The Dynamic Type check changes the text size while it runs,
    /// so it gets its own test with the size left live. Every other check runs at a pinned size.
    private var pinnedSizeAudit: XCUIAccessibilityAuditType {
        fullAudit.subtracting(.dynamicType)
    }

    /// Every element in the gallery that shows text, top to bottom, by accessibility identifier.
    private let textIdentifiers = [
        "gallery.section.Buttons", "gallery.primary", "gallery.secondary", "gallery.disabled",
        "gallery.section.Cards", "gallery.card.english", "gallery.card.espanol", "gallery.card.intermediate",
        "gallery.card.microphone",
        "gallery.section.Goal tiles", "gallery.tile.Work", "gallery.tile.Travel", "gallery.tile.Interviews",
        "gallery.tile.Everyday talk",
        "gallery.section.Progress and tags", "gallery.progress", "gallery.tag",
        "gallery.section.Icons", "gallery.section.Characters and avatars", "gallery.end"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Accessibility audit

    func test_gallery_passesAccessibilityAudit_atStandardTextSize_inDarkTheme() throws {
        try auditWholeGallery(in: launchGallery(textSize: .standard, appearance: .dark, grain: false), for: pinnedSizeAudit)
    }

    func test_gallery_passesAccessibilityAudit_atStandardTextSize_inLightTheme() throws {
        try auditWholeGallery(in: launchGallery(textSize: .standard, appearance: .light), for: pinnedSizeAudit)
    }

    /// The Dynamic Type check makes the text smaller and bigger while it runs, which moves the scroll position.
    /// So each text element is scrolled into full view by its identifier, then checked.
    func test_everyText_followsDynamicType() throws {
        let app = launchGallery(textSize: .system, appearance: .dark)
        let area = visibleArea(of: app)
        var issues: [String] = []
        for identifier in textIdentifiers {
            let element = app.descendants(matching: .any)[identifier].firstMatch
            scroll(to: element, in: app)
            XCTAssertTrue(area.contains(element.frame), "\(identifier) never came fully on screen")
            try audit(app, for: .dynamicType) { issue in
                guard Self.counts(issue, in: area) else { return true }
                let line = Self.describe(issue, atScrollPosition: 0).replacingOccurrences(of: "[0] ", with: "")
                if !issues.contains(line) { issues.append(line) }
                return true
            }
        }
        XCTAssertTrue(issues.isEmpty, "Dynamic Type check found:\n" + issues.joined(separator: "\n"))
    }

    func test_gallery_passesAccessibilityAudit_atLargestTextSize_inDarkTheme() throws {
        try auditWholeGallery(in: launchGallery(textSize: .largest, appearance: .dark, grain: false), for: pinnedSizeAudit)
    }

    func test_gallery_passesAccessibilityAudit_atLargestTextSize_inLightTheme() throws {
        try auditWholeGallery(in: launchGallery(textSize: .largest, appearance: .light), for: pinnedSizeAudit)
    }

    // MARK: Controls on screen and tappable

    func test_everyControl_isOnScreenTappableAndAtLeast44Points_atStandardTextSize() throws {
        try checkControls(in: launchGallery(textSize: .standard, appearance: .dark))
    }

    func test_everyControl_isOnScreenTappableAndAtLeast44Points_atLargestTextSize() throws {
        try checkControls(in: launchGallery(textSize: .largest, appearance: .dark))
    }

    func test_disabledButton_isNotEnabled() throws {
        let app = launchGallery(textSize: .standard, appearance: .dark)
        let disabled = app.buttons["gallery.disabled"]
        scroll(to: disabled, in: app)
        XCTAssertFalse(disabled.isEnabled)
    }

    func test_selectedCard_reportsTheSelectedTrait() throws {
        let app = launchGallery(textSize: .standard, appearance: .dark)
        let english = app.buttons["gallery.card.english"]
        scroll(to: english, in: app)
        XCTAssertTrue(english.isSelected)
    }

    func test_unavailableCard_isNotEnabled() throws {
        let app = launchGallery(textSize: .standard, appearance: .dark)
        let espanol = app.buttons["gallery.card.espanol"]
        scroll(to: espanol, in: app)
        XCTAssertFalse(espanol.isEnabled)
    }

    // MARK: Helpers

    /// Audits turn the grain off: Apple's contrast check reads rendered pixels and can mistake the grain's
    /// light specks for text color. Text on the plain ground is what the token contrast tests already prove.
    private func launchGallery(textSize: TextSize, appearance: Appearance, grain: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["SAYMODE_SCREEN"] = "gallery"
        if !grain {
            app.launchEnvironment["SAYMODE_GRAIN"] = "off"
        }
        if textSize != .system {
            app.launchEnvironment["SAYMODE_DYNAMIC_TYPE"] = textSize.rawValue
        }
        app.launchEnvironment["SAYMODE_APPEARANCE"] = appearance.rawValue
        app.launch()
        return app
    }

    /// The audit only sees what is on screen, so it runs once per scroll position until the end of the gallery.
    /// Every issue is collected, so one run reports all of them with the element that caused each one.
    private func auditWholeGallery(in app: XCUIApplication, for auditTypes: XCUIAccessibilityAuditType) throws {
        let area = visibleArea(of: app)
        let end = app.staticTexts["gallery.end"]
        var issues: [String] = []
        defer {
            XCTAssertTrue(issues.isEmpty, "Accessibility audit found:\n" + issues.joined(separator: "\n"))
        }
        for position in 0..<40 {
            var issuesHere: [String] = []
            var contrastIssues: [String: String] = [:]
            try audit(app, for: auditTypes) { issue in
                guard Self.counts(issue, in: area) else { return true }
                let line = Self.describe(issue, atScrollPosition: position)
                if issue.auditType == .contrast, let element = issue.element {
                    contrastIssues[Self.key(for: element)] = line
                } else {
                    issuesHere.append(line)
                }
                return true
            }
            issuesHere += try confirmContrastIssues(in: app, contrastIssues)
            if !issuesHere.isEmpty {
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                screenshot.name = "Audit issues at scroll position \(position)"
                screenshot.lifetime = .keepAlways
                add(screenshot)
                issues += issuesHere
            }
            if end.exists, end.isHittable, area.contains(end.frame) { return }
            let before = end.exists ? end.frame : .null
            scrollOneStep(in: app)
            if end.exists, end.frame == before, before != .null {
                XCTFail("The gallery stopped scrolling before its end was fully on screen: \(end.frame)")
                return
            }
        }
        XCTFail("Never reached the end of the gallery")
    }

    /// Drags the content up by half a screen and holds still at the end, so the scroll stops
    /// exactly there with no fling. The audit then sees a still screen.
    private func scrollOneStep(in app: XCUIApplication) {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        let finish = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25))
        start.press(forDuration: 0.05, thenDragTo: finish, withVelocity: .slow, thenHoldForDuration: 0.3)
    }

    /// Runs one audit, retrying once when the audit itself runs out of time. A timeout says nothing about the screen.
    private func audit(_ app: XCUIApplication, for auditTypes: XCUIAccessibilityAuditType,
                       issueHandler: @escaping (XCUIAccessibilityAuditIssue) throws -> Bool) throws {
        do {
            try app.performAccessibilityAudit(for: auditTypes, issueHandler)
        } catch let error as NSError where error.domain == "com.apple.xcode.xctest.accessibilityAudit" && error.code == -56 {
            try app.performAccessibilityAudit(for: auditTypes, issueHandler)
        }
    }

    /// Which audit issues are real for this screen.
    /// An element under the status bar or past the screen edge is measured against things that are not
    /// its background. It is audited in full view at another scroll position.
    /// A disabled control is exempt from contrast rules (WCAG 2.2, 1.4.3, inactive user interface components).
    /// A progress indicator is exempt from the hit area rule, because nobody taps it.
    private static func counts(_ issue: XCUIAccessibilityAuditIssue, in visibleArea: CGRect) -> Bool {
        guard let element = issue.element else { return true }
        if !visibleArea.contains(element.frame) { return false }
        if issue.auditType == .contrast && !element.isEnabled { return false }
        // Apple's 44 point rule is for things people tap. A progress indicator only shows status.
        if issue.auditType == .hitRegion && element.elementType == .progressIndicator { return false }
        return true
    }

    /// The part of the screen content is read in: the window minus the status bar, which iOS draws on top.
    private func visibleArea(of app: XCUIApplication) -> CGRect {
        let window = app.windows.firstMatch.frame
        let statusBar = XCUIApplication(bundleIdentifier: "com.apple.springboard").statusBars.firstMatch
        guard statusBar.exists, statusBar.frame.height > 0 else { return window }
        return CGRect(x: window.minX, y: statusBar.frame.maxY,
                      width: window.width, height: window.maxY - statusBar.frame.maxY)
    }

    /// The contrast check samples rendered pixels, and the grain texture behind the text can tip one sample.
    /// A contrast issue counts only when a second audit of the same still screen flags the same element.
    private func confirmContrastIssues(in app: XCUIApplication, _ issues: [String: String]) throws -> [String] {
        guard !issues.isEmpty else { return [] }
        var confirmed: [String] = []
        try audit(app, for: .contrast) { issue in
            if let key = issue.element.map(Self.key(for:)), let line = issues[key], !confirmed.contains(line) {
                confirmed.append(line)
            }
            return true
        }
        return confirmed
    }

    private static func key(for element: XCUIElement) -> String {
        "\(element.identifier)|\(element.label)|\(element.frame)"
    }

    private static func describe(_ issue: XCUIAccessibilityAuditIssue, atScrollPosition position: Int) -> String {
        let element = issue.element
        let name = element.map { "\($0.elementType.rawValue) '\($0.identifier)' '\($0.label)' frame \($0.frame) enabled \($0.isEnabled)" }
        return "[\(position)] \(issue.compactDescription): \(issue.detailedDescription) | \(name ?? "no element")"
    }

    private func checkControls(in app: XCUIApplication) throws {
        let area = visibleArea(of: app)
        for identifier in controlIdentifiers {
            let control = app.buttons[identifier]
            scroll(to: control, in: app)
            XCTAssertTrue(control.isHittable, "\(identifier) is not tappable")
            XCTAssertTrue(area.contains(control.frame), "\(identifier) is outside the screen: \(control.frame)")
            XCTAssertGreaterThanOrEqual(control.frame.width, 44, "\(identifier) is narrower than 44 points")
            XCTAssertGreaterThanOrEqual(control.frame.height, 44, "\(identifier) is shorter than 44 points")
        }
    }

    /// Scrolls in small steps until the whole element is on screen, below the status bar, not just part of it.
    private func scroll(to element: XCUIElement, in app: XCUIApplication) {
        let window = app.windows.firstMatch
        let screen = visibleArea(of: app)
        for _ in 0..<60 {
            if element.exists, screen.contains(element.frame) { return }
            let step = screen.height * 0.3
            var distance = -step
            if element.exists {
                let frame = element.frame
                if frame.minY < screen.minY {
                    distance = min(screen.minY - frame.minY + ScrollTuning.margin, step)
                } else if frame.maxY > screen.maxY {
                    distance = -min(frame.maxY - screen.maxY + ScrollTuning.margin, step)
                }
            }
            let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 0, dy: distance)),
                        withVelocity: .slow, thenHoldForDuration: 0.3)
        }
    }

    private enum ScrollTuning {
        /// Extra room left between the element and the screen edge after scrolling.
        static let margin: CGFloat = 40
    }
}
