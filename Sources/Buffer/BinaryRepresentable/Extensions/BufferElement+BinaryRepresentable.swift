//
//  Created by Anton Spivak
//

// MARK: - BufferElement + BinaryRepresentable

extension BufferElement: BinaryRepresentable {
    /// Initializes object with`Binary`, e.g. `[BinaryElement]` array
    /// - parameter binary: the `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of given buffer, e.g. `.big` or `.little`, default
    /// is `.big`
    public init(binary: Binary, endianness: Endianness = .big) {
        var binary = binary

        switch endianness {
        case .big:
            binary.reverse()
        case .little:
            break
        }

        let devider = Self.bitWidth - (binary.count % Self.bitWidth)
        if devider > 0 && devider < Self.bitWidth {
            binary = binary + .init(repeating: .zero, count: devider)
        }

        var value = Self(0)
        stride(from: 0, to: Self.bitWidth, by: 1).forEach({
            guard binary[$0] == .one
            else {
                return
            }

            value |= (0x1 << $0)
        })

        self = value
    }

    /// Returns `Binary`, e.g. `[BinaryElement]` array
    /// - parameter endianness: the `Endianness` of buffer, e.g. `.big` or `.little`, default is
    /// `.big`
    /// - parameter truncation: the `Truncation` rule for the result binary, default is `.none`
    public func binary(
        endianness: Endianness = .big,
        truncation: BinaryTruncation = .none
    ) -> Binary {
        var binary = stride(from: 0, to: Self.bitWidth, by: 1).map({
            BinaryElement(rawValue: (littleEndian & (0x1 << $0)) != 0)
        })

        switch endianness {
        case .big:
            binary.reverse()
        case .little:
            break
        }

        return truncation.truncate(binary, endinness: endianness)
    }
}
