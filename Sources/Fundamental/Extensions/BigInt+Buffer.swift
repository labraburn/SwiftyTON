//
//  Created by Anton Spivak
//

import BigInt
import Buffbit
import Foundation

// MARK: - BigInt + BufferRepresentable

extension BigInt: BufferRepresentable {
    public init(buffer: Buffer, endianness: Endianness = .big) {
        var buffer = buffer
        switch endianness {
        case .big:
            break
        case .little:
            buffer.reverse()
        }

        self.init(Data(buffer))
    }

    public func buffer(
        endianness: Endianness = .big,
        truncation: BufferTruncation = .none
    ) -> Buffer {
        var buffer = Buffer(serialize())
        switch endianness {
        case .big:
            break
        case .little:
            buffer.reverse()
        }

        return truncation.truncate(buffer, endinness: endianness)
    }
}

// MARK: - BigUInt + BufferRepresentable

extension BigUInt: BufferRepresentable {
    public init(buffer: Buffer, endianness: Endianness = .big) {
        var buffer = buffer
        switch endianness {
        case .big:
            break
        case .little:
            buffer.reverse()
        }

        self.init(Data(buffer))
    }

    public func buffer(
        endianness: Endianness = .big,
        truncation: BufferTruncation = .none
    ) -> Buffer {
        var buffer = Buffer(serialize())
        switch endianness {
        case .big:
            break
        case .little:
            buffer.reverse()
        }

        return truncation.truncate(buffer, endinness: endianness)
    }
}

// MARK: - BigInt + BinaryRepresentable

extension BigInt: BinaryRepresentable {}

// MARK: - BigUInt + BinaryRepresentable

extension BigUInt: BinaryRepresentable {}
