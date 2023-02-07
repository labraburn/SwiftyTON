//
//  Created by Anton Spivak
//

import Buffer

// MARK: - VariableInteger

public protocol VariableInteger {
    associatedtype Value: BinaryInteger

    var length: Int { get }
    var value: Value { get }

    var isZero: Bool { get }

    init(_ value: Value, length: Int)
}

// MARK: BufferRepresentable

public extension VariableInteger where Value: BufferRepresentable {
    init(buffer: Buffer, endianness: Endianness = .big) {
        fatalError("TODO: //")
    }

    func buffer(
        endianness: Endianness = .big,
        truncation: BufferTruncation = .none
    ) -> Buffer {
        value.buffer(endianness: endianness, truncation: truncation)
    }
}
