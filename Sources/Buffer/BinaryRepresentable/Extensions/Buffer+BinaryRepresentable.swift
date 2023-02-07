//
//  Created by Anton Spivak
//

extension Buffer: BinaryRepresentable {
    /// Initializes object with`Binary`, e.g. `[BinaryElement]` array
    /// - parameter binary: the `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of given buffer, e.g. `.big` or `.little`, default
    /// is `.big`
    public init(binary: Binary, endianness: Endianness = .big) {
        var binary = binary

        let devider = BufferElement.bitWidth - (binary.count % BufferElement.bitWidth)
        if devider > 0 && devider < BufferElement.bitWidth {
            switch endianness {
            case .big:
                binary = .init(repeating: .zero, count: devider) + binary
            case .little:
                binary = binary + .init(repeating: .zero, count: devider)
            }
        }

        let chunks = binary.chunked(withSliceSize: BufferElement.bitWidth)
        self = chunks.reduce(into: Buffer(), {
            $0 += [BufferElement(binary: $1, endianness: endianness)]
        })
    }

    /// Returns `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of buffer, e.g. `.big` or `.little`, default is
    /// `.big`
    /// - parameter truncation: the `Truncation` rule for the result binary, default is `.none`
    public func binary(
        endianness: Endianness = .big,
        truncation: BinaryTruncation = .none
    ) -> Binary {
        let binary = flatMap({
            $0.binary(endianness: endianness, truncation: .none)
        })
        return truncation.truncate(binary, endinness: endianness)
    }
}
