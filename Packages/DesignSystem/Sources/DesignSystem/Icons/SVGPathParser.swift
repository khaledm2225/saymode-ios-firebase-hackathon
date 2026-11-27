import CoreGraphics
import Foundation

/// Turns SVG path data (the `d` attribute) into a Core Graphics path.
/// Supports every command: M L H V C S Q T A Z, absolute and relative, with implicit repeats.
enum SVGPathParser {
    enum Failure: Error, Equatable {
        case empty
        case unknownCommand(Character)
        case missingCommand
        case malformedNumber
    }

    static func parse(_ data: String) throws -> CGMutablePath {
        var scanner = Scanner(bytes: Array(data.utf8))
        let path = CGMutablePath()
        var current = CGPoint.zero
        var subpathStart = CGPoint.zero
        var lastCubicControl: CGPoint?
        var lastQuadControl: CGPoint?
        var command: UInt8?
        var drewSomething = false

        while true {
            scanner.skipSeparators()
            guard let next = scanner.peek else { break }
            if Scanner.isCommand(next) {
                command = next
                scanner.advance()
            } else if command == nil {
                throw Failure.missingCommand
            }
            guard let active = command else { throw Failure.missingCommand }
            let relative = Scanner.isLowercase(active)
            let origin = relative ? current : .zero

            switch Scanner.uppercased(active) {
            case UInt8(ascii: "M"):
                let point = try scanner.point(offsetBy: origin)
                path.move(to: point)
                current = point
                subpathStart = point
                // Coordinates after a move are implicit line commands.
                command = relative ? UInt8(ascii: "l") : UInt8(ascii: "L")
                lastCubicControl = nil
                lastQuadControl = nil
            case UInt8(ascii: "L"):
                let point = try scanner.point(offsetBy: origin)
                path.addLine(to: point)
                current = point
                lastCubicControl = nil
                lastQuadControl = nil
            case UInt8(ascii: "H"):
                let x = try scanner.number() + origin.x
                current = CGPoint(x: x, y: current.y)
                path.addLine(to: current)
                lastCubicControl = nil
                lastQuadControl = nil
            case UInt8(ascii: "V"):
                let y = try scanner.number() + origin.y
                current = CGPoint(x: current.x, y: y)
                path.addLine(to: current)
                lastCubicControl = nil
                lastQuadControl = nil
            case UInt8(ascii: "C"):
                let control1 = try scanner.point(offsetBy: origin)
                let control2 = try scanner.point(offsetBy: origin)
                let end = try scanner.point(offsetBy: origin)
                path.addCurve(to: end, control1: control1, control2: control2)
                current = end
                lastCubicControl = control2
                lastQuadControl = nil
            case UInt8(ascii: "S"):
                let control1 = reflect(lastCubicControl, about: current)
                let control2 = try scanner.point(offsetBy: origin)
                let end = try scanner.point(offsetBy: origin)
                path.addCurve(to: end, control1: control1, control2: control2)
                current = end
                lastCubicControl = control2
                lastQuadControl = nil
            case UInt8(ascii: "Q"):
                let control = try scanner.point(offsetBy: origin)
                let end = try scanner.point(offsetBy: origin)
                path.addQuadCurve(to: end, control: control)
                current = end
                lastQuadControl = control
                lastCubicControl = nil
            case UInt8(ascii: "T"):
                let control = reflect(lastQuadControl, about: current)
                let end = try scanner.point(offsetBy: origin)
                path.addQuadCurve(to: end, control: control)
                current = end
                lastQuadControl = control
                lastCubicControl = nil
            case UInt8(ascii: "A"):
                let radiusX = try scanner.number()
                let radiusY = try scanner.number()
                let rotation = try scanner.number()
                let largeArc = try scanner.flag()
                let sweep = try scanner.flag()
                let end = try scanner.point(offsetBy: origin)
                addArc(to: path, from: current, to: end, radiusX: radiusX, radiusY: radiusY,
                       rotationDegrees: rotation, largeArc: largeArc, sweep: sweep)
                current = end
                lastCubicControl = nil
                lastQuadControl = nil
            case UInt8(ascii: "Z"):
                path.closeSubpath()
                current = subpathStart
                lastCubicControl = nil
                lastQuadControl = nil
                // A close takes no numbers, so the next token must be a new command.
                command = nil
            default:
                throw Failure.unknownCommand(Character(UnicodeScalar(active)))
            }
            drewSomething = true
        }

        guard drewSomething else { throw Failure.empty }
        return path
    }

    private static func reflect(_ control: CGPoint?, about point: CGPoint) -> CGPoint {
        guard let control else { return point }
        return CGPoint(x: 2 * point.x - control.x, y: 2 * point.y - control.y)
    }

    /// Converts an SVG endpoint arc to cubic curves (SVG 1.1, appendix F.6).
    private static func addArc(to path: CGMutablePath, from start: CGPoint, to end: CGPoint,
                               radiusX: CGFloat, radiusY: CGFloat, rotationDegrees: CGFloat,
                               largeArc: Bool, sweep: Bool) {
        guard start != end else { return }
        var rx = abs(radiusX)
        var ry = abs(radiusY)
        guard rx > 0, ry > 0 else {
            path.addLine(to: end)
            return
        }
        let phi = rotationDegrees * .pi / 180
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)
        let halfDX = (start.x - end.x) / 2
        let halfDY = (start.y - end.y) / 2
        let x1 = cosPhi * halfDX + sinPhi * halfDY
        let y1 = -sinPhi * halfDX + cosPhi * halfDY

        let lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
        if lambda > 1 {
            rx *= lambda.squareRoot()
            ry *= lambda.squareRoot()
        }

        let numerator = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1
        let denominator = rx * rx * y1 * y1 + ry * ry * x1 * x1
        let sign: CGFloat = largeArc == sweep ? -1 : 1
        let coefficient = sign * max(0, numerator / denominator).squareRoot()
        let centerXPrime = coefficient * rx * y1 / ry
        let centerYPrime = -coefficient * ry * x1 / rx
        let center = CGPoint(x: cosPhi * centerXPrime - sinPhi * centerYPrime + (start.x + end.x) / 2,
                             y: sinPhi * centerXPrime + cosPhi * centerYPrime + (start.y + end.y) / 2)

        let startVector = CGPoint(x: (x1 - centerXPrime) / rx, y: (y1 - centerYPrime) / ry)
        let endVector = CGPoint(x: (-x1 - centerXPrime) / rx, y: (-y1 - centerYPrime) / ry)
        let startAngle = angle(from: CGPoint(x: 1, y: 0), to: startVector)
        var sweepAngle = angle(from: startVector, to: endVector)
        if !sweep && sweepAngle > 0 { sweepAngle -= 2 * .pi }
        if sweep && sweepAngle < 0 { sweepAngle += 2 * .pi }

        let segments = max(1, Int((abs(sweepAngle) / (.pi / 2)).rounded(.up)))
        let delta = sweepAngle / CGFloat(segments)
        let handle = 4 / 3 * tan(delta / 4)

        func point(at theta: CGFloat) -> CGPoint {
            CGPoint(x: center.x + rx * cos(theta) * cosPhi - ry * sin(theta) * sinPhi,
                    y: center.y + rx * cos(theta) * sinPhi + ry * sin(theta) * cosPhi)
        }
        func derivative(at theta: CGFloat) -> CGPoint {
            CGPoint(x: -rx * sin(theta) * cosPhi - ry * cos(theta) * sinPhi,
                    y: -rx * sin(theta) * sinPhi + ry * cos(theta) * cosPhi)
        }

        for index in 0..<segments {
            let from = startAngle + CGFloat(index) * delta
            let to = from + delta
            let segmentStart = point(at: from)
            let segmentEnd = index == segments - 1 ? end : point(at: to)
            let startTangent = derivative(at: from)
            let endTangent = derivative(at: to)
            path.addCurve(to: segmentEnd,
                          control1: CGPoint(x: segmentStart.x + handle * startTangent.x, y: segmentStart.y + handle * startTangent.y),
                          control2: CGPoint(x: segmentEnd.x - handle * endTangent.x, y: segmentEnd.y - handle * endTangent.y))
        }
    }

    private static func angle(from first: CGPoint, to second: CGPoint) -> CGFloat {
        atan2(first.x * second.y - first.y * second.x, first.x * second.x + first.y * second.y)
    }
}

/// Reads numbers, flags and commands from SVG path data.
private struct Scanner {
    let bytes: [UInt8]
    var index = 0

    var peek: UInt8? { index < bytes.count ? bytes[index] : nil }

    mutating func advance() { index += 1 }

    static func isCommand(_ byte: UInt8) -> Bool {
        let letter = (byte >= UInt8(ascii: "A") && byte <= UInt8(ascii: "Z")) || (byte >= UInt8(ascii: "a") && byte <= UInt8(ascii: "z"))
        // "e" and "E" belong to numbers (exponents), never commands.
        return letter && byte != UInt8(ascii: "e") && byte != UInt8(ascii: "E")
    }

    static func isLowercase(_ byte: UInt8) -> Bool {
        byte >= UInt8(ascii: "a") && byte <= UInt8(ascii: "z")
    }

    static func uppercased(_ byte: UInt8) -> UInt8 {
        isLowercase(byte) ? byte - 32 : byte
    }

    mutating func skipSeparators() {
        while let byte = peek, byte == UInt8(ascii: " ") || byte == UInt8(ascii: ",") || byte == UInt8(ascii: "\n")
                || byte == UInt8(ascii: "\t") || byte == UInt8(ascii: "\r") {
            advance()
        }
    }

    mutating func point(offsetBy origin: CGPoint) throws -> CGPoint {
        let x = try number()
        let y = try number()
        return CGPoint(x: x + origin.x, y: y + origin.y)
    }

    mutating func flag() throws -> Bool {
        skipSeparators()
        guard let byte = peek, byte == UInt8(ascii: "0") || byte == UInt8(ascii: "1") else {
            throw SVGPathParser.Failure.malformedNumber
        }
        advance()
        return byte == UInt8(ascii: "1")
    }

    mutating func number() throws -> CGFloat {
        skipSeparators()
        let start = index
        if let sign = peek, sign == UInt8(ascii: "-") || sign == UInt8(ascii: "+") { advance() }
        var sawDigit = false
        var sawDot = false
        while let byte = peek {
            if byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9") {
                sawDigit = true
                advance()
            } else if byte == UInt8(ascii: ".") && !sawDot {
                sawDot = true
                advance()
            } else {
                break
            }
        }
        if sawDigit, let exponent = peek, exponent == UInt8(ascii: "e") || exponent == UInt8(ascii: "E") {
            advance()
            if let sign = peek, sign == UInt8(ascii: "-") || sign == UInt8(ascii: "+") { advance() }
            while let byte = peek, byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9") { advance() }
        }
        guard sawDigit, let text = String(bytes: bytes[start..<index], encoding: .ascii), let value = Double(text) else {
            throw SVGPathParser.Failure.malformedNumber
        }
        return CGFloat(value)
    }
}
