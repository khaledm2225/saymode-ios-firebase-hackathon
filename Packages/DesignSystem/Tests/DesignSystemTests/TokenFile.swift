import Foundation
import UIKit
import XCTest

/// Reads the kit's design-tokens.json, the single source of truth that the Swift tokens must match.
struct TokenFile {
    private let root: [String: Any]

    init() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "design-tokens", withExtension: "json"))
        let data = try Data(contentsOf: url)
        root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func string(_ path: String) throws -> String {
        try XCTUnwrap(value(at: path) as? String, "Missing string at \(path)")
    }

    func number(_ path: String) throws -> Double {
        let number = try XCTUnwrap(value(at: path) as? NSNumber, "Missing number at \(path)")
        return number.doubleValue
    }

    private func value(at path: String) -> Any? {
        path.split(separator: ".").reduce(root as Any?) { node, key in
            (node as? [String: Any])?[String(key)]
        }
    }
}

extension UIColor {
    /// The color as an uppercase sRGB hex string, for example "#FFD21F".
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let channels = [red, green, blue].map { Int(($0 * 255).rounded()) }
        return String(format: "#%02X%02X%02X", channels[0], channels[1], channels[2])
    }
}
