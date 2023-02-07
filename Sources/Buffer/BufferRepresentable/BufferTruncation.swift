//
//  Created by Anton Spivak
//

// MARK: - BufferTruncation

public struct BufferTruncation {
    // MARK: Lifecycle

    public init(_ function: Function?) {
        self.function = function
    }

    // MARK: Public

    public typealias Function = (_ original: Buffer, _ endinness: Endianness) -> Buffer

    public func truncate(_ original: Buffer, endinness: Endianness) -> Buffer {
        guard let function
        else {
            return original
        }

        return function(original, endinness)
    }

    // MARK: Private

    private let function: Function?
}

public extension BufferTruncation {
    /// No truncation will be applied
    static var none: BufferTruncation {
        BufferTruncation(nil)
    }

    /// Standart truncation for the buffer. All zeroes dependent on `Endianness` will be truncated
    static var standart: BufferTruncation {
        BufferTruncation({ original, endianness in
            switch endianness {
            case .big:
                guard let index = original.firstIndex(where: { $0 != 0 })
                else {
                    return []
                }
                return Array(original[index ..< original.count])
            case .little:
                guard let index = original.lastIndex(where: { $0 != 0 })
                else {
                    return original
                }
                return Array(original[0 ... index])
            }
        })
    }
}
