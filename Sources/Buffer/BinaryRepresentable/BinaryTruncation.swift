//
//  Created by Anton Spivak
//

// MARK: - BinaryTruncation

public struct BinaryTruncation {
    // MARK: Lifecycle

    public init(_ function: Function?) {
        self.function = function
    }

    // MARK: Public

    public typealias Function = (_ original: Binary, _ endinness: Endianness) -> Binary

    // MARK: Internal

    internal func truncate(_ original: Binary, endinness: Endianness) -> Binary {
        guard let function
        else {
            return original
        }

        return function(original, endinness)
    }

    // MARK: Private

    private let function: Function?
}

public extension BinaryTruncation {
    /// No truncation will be applied
    static var none: BinaryTruncation {
        BinaryTruncation(nil)
    }

    /// Standart truncation for the binary. All zeroes dependent on `Endianness` will be truncated
    static var standart: BinaryTruncation {
        BinaryTruncation({ original, endianness in
            switch endianness {
            case .big:
                guard let index = original.firstIndex(where: { $0 == .one })
                else {
                    return []
                }
                return Array(original[index ..< original.count])
            case .little:
                guard let index = original.lastIndex(where: { $0 == .one })
                else {
                    return original
                }
                return Array(original[0 ... index])
            }
        })
    }
}
