//
//  Created by Anton Spivak
//

public extension ExpressibleByBuffer where Self: FixedWidthInteger {
    /// Initializes object with`Buffer`, e.g. `[UInt8]` array
    /// - parameter buffer: the `Buffer`, e.g. `[UInt8]` array
    /// - parameter endianness: the `Endianness` of given buffer, e.g. `.big` or `.little`, default
    /// is `.big`
    init(buffer: Buffer, endianness: Endianness = .big) {
        var buffer = buffer

        switch endianness {
        case .big:
            buffer.reverse()
        case .little:
            break
        }

        let expectedBytesCount = MemoryLayout<Self>.size
        if expectedBytesCount > buffer.count {
            buffer = buffer + .init(repeating: 0x0, count: expectedBytesCount - buffer.count)
        }

        self = buffer.withUnsafeBytes({
            $0.load(as: Self.self)
        })
    }
}

public extension BufferConvertible where Self: FixedWidthInteger {
    /// Returns `Buffer`, e.g. `[UInt8]` array
    /// - parameter endianness: the `Endianness` of buffer array, e.g. `.big` or `.little`
    /// - parameter truncation: the `Truncation` rule for the result buffer, default is `.none`
    func buffer(
        endianness: Endianness = .big,
        truncation: BufferTruncation = .none
    ) -> Buffer {
        var value: Self

        switch endianness {
        case .big:
            value = bigEndian
        case .little:
            value = littleEndian
        }

        let buffer = withUnsafePointer(to: &value, {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size, {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<Self>.size))
            })
        })

        return truncation.truncate(buffer, endinness: endianness)
    }
}

// MARK: - UInt8 + BufferRepresentable

extension UInt8: BufferRepresentable {}

// MARK: - UInt16 + BufferRepresentable

extension UInt16: BufferRepresentable {}

// MARK: - UInt32 + BufferRepresentable

extension UInt32: BufferRepresentable {}

// MARK: - UInt64 + BufferRepresentable

extension UInt64: BufferRepresentable {}

// MARK: - Int8 + BufferRepresentable

extension Int8: BufferRepresentable {}

// MARK: - Int16 + BufferRepresentable

extension Int16: BufferRepresentable {}

// MARK: - Int32 + BufferRepresentable

extension Int32: BufferRepresentable {}

// MARK: - Int64 + BufferRepresentable

extension Int64: BufferRepresentable {}
