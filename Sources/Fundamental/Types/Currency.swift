//
//  Created by Anton Spivak
//

import Foundation

// MARK: - Currency

public struct Currency {
    // MARK: Lifecycle

    /// - parameter value: An currency value in `nano`
    public init(value: Int64) {
        self.value = value > 0 ? value : 0
    }

    // MARK: Public

    /// Represents `nano` value
    public private(set) var value: Int64
}

// MARK: BinaryInteger

extension Currency: BinaryInteger {
    public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
        guard let value = Int64(exactly: source)
        else {
            return nil
        }

        self.init(value: value)
    }

    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard let value = Int64(exactly: source)
        else {
            return nil
        }

        self.init(value: value)
    }

    public init<T>(_ source: T) where T: BinaryFloatingPoint {
        self.init(value: Int64(source))
    }

    public init<T>(_ source: T) where T: BinaryInteger {
        self.init(value: Int64(source))
    }

    public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
        self.init(value: Int64(truncatingIfNeeded: source))
    }

    public init<T>(clamping source: T) where T: BinaryInteger {
        self.init(value: Int64(clamping: source))
    }

    public typealias Words = Int64.Words
    public typealias Magnitude = Int64.Magnitude

    public static var isSigned: Bool {
        Int64.isSigned
    }

    public var words: Int64.Words {
        value.words
    }

    public var bitWidth: Int {
        value.bitWidth
    }

    public var trailingZeroBitCount: Int {
        value.trailingZeroBitCount
    }

    public var magnitude: Int64.Magnitude {
        value.magnitude
    }

    public func distance(to other: Currency) -> Int {
        value.distance(to: other.value)
    }

    public static func <<= <RHS>(lhs: inout Currency, rhs: RHS) where RHS: BinaryInteger {
        lhs.value <<= rhs
    }

    public static func >>= <RHS>(lhs: inout Currency, rhs: RHS) where RHS: BinaryInteger {
        lhs.value >>= rhs
    }

    public static prefix func ~ (x: Currency) -> Currency {
        Currency(value: ~x.value)
    }

    public static func + (lhs: Currency, rhs: Currency) -> Currency {
        Currency(value: lhs.value + rhs.value)
    }

    public static func - (lhs: Currency, rhs: Currency) -> Currency {
        Currency(value: lhs.value - rhs.value)
    }

    public static func += (lhs: inout Currency, rhs: Currency) {
        lhs.value += rhs.value
    }

    public static func -= (lhs: inout Currency, rhs: Currency) {
        lhs.value -= rhs.value
    }

    public static func / (lhs: Currency, rhs: Currency) -> Currency {
        Currency(value: lhs.value / rhs.value)
    }

    public static func /= (lhs: inout Currency, rhs: Currency) {
        lhs.value /= rhs.value
    }

    public static func % (lhs: Currency, rhs: Currency) -> Currency {
        Currency(value: lhs.value % rhs.value)
    }

    public static func %= (lhs: inout Currency, rhs: Currency) {
        lhs.value %= rhs.value
    }

    public static func * (lhs: Currency, rhs: Currency) -> Currency {
        Currency(value: lhs.value * rhs.value)
    }

    public static func *= (lhs: inout Currency, rhs: Currency) {
        lhs.value *= rhs.value
    }

    public static func &= (lhs: inout Currency, rhs: Currency) {
        lhs.value &= rhs.value
    }

    public static func |= (lhs: inout Currency, rhs: Currency) {
        lhs.value |= rhs.value
    }

    public static func ^= (lhs: inout Currency, rhs: Currency) {
        lhs.value ^= rhs.value
    }
}

// MARK: ExpressibleByIntegerLiteral

extension Currency: ExpressibleByIntegerLiteral {
    /// Represents `nano` value
    public typealias IntegerLiteralType = Int64

    /// - parameter integerLiteral: An currency value in `nano`
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value: value)
    }
}

// MARK: CustomStringConvertible

extension Currency: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

// MARK: Codable

extension Currency: Codable {}

// MARK: Hashable

extension Currency: Hashable {}
