//
//  Created by Anton Spivak
//

// MARK: - BufferConvertible

public protocol BufferConvertible {
    /// Returns `Buffer`, e.g. `[UInt8]` array
    /// - parameter endianness: the `Endianness` of buffer array, e.g. `.big` or `.little`
    /// - parameter truncation: the `Truncation` rule for the result buffer
    func buffer(endianness: Endianness, truncation: BufferTruncation) -> Buffer
}

// MARK: - ExpressibleByBuffer

public protocol ExpressibleByBuffer {
    /// Initializes object with`Buffer`, e.g. `[UInt8]` array
    /// - parameter buffer: the `Buffer`, e.g. `[UInt8]` array
    /// - parameter endianness: the `Endianness` of given buffer, e.g. `.big` or `.little`
    init(buffer: Buffer, endianness: Endianness)
}

public typealias BufferRepresentable = BufferConvertible & ExpressibleByBuffer
