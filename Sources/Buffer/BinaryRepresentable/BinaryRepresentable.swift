//
//  Created by Anton Spivak
//

// MARK: - BinaryConvertible

public protocol BinaryConvertible {
    /// Returns `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of buffer, e.g. `.big` or `.little`
    /// - parameter truncation: the `Truncation` rule for the result binary
    func binary(endianness: Endianness, truncation: BinaryTruncation) -> Binary
}

// MARK: - ExpressibleByBinary

public protocol ExpressibleByBinary {
    /// Initializes object with`Binary`, e.g. `[BinaryElement]` array
    /// - parameter binary: the `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of given buffer, e.g. `.big` or `.little`
    init(binary: Binary, endianness: Endianness)
}

public typealias BinaryRepresentable = BinaryConvertible & ExpressibleByBinary
