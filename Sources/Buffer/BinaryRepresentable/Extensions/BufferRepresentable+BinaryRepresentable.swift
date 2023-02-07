//
//  Created by Anton Spivak
//

public extension ExpressibleByBinary where Self: ExpressibleByBuffer {
    /// Initializes object with`Binary`, e.g. `[BinaryElement]` array
    /// - parameter binary: the `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of given buffer, e.g. `.big` or `.little`, default
    /// is `.big`
    init(binary: Binary, endianness: Endianness = .big) {
        let buffer = Buffer(binary: binary, endianness: endianness)
        self.init(buffer: buffer, endianness: endianness)
    }
}

public extension BinaryConvertible where Self: BufferConvertible {
    /// Returns `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of buffer, e.g. `.big` or `.little`, default is
    /// `.big`
    /// - parameter truncation: the `Truncation` rule for the result binary, default is `.none`
    func binary(
        endianness: Endianness = .big,
        truncation: BinaryTruncation = .none
    ) -> Binary {
        let buffer = buffer(endianness: endianness, truncation: .none)
        return buffer.binary(endianness: endianness, truncation: truncation)
    }
}
