//
//  Created by Anton Spivak
//

import BigInt
import Buffer

public extension CellEncodable where Self: BinaryConvertible {
    func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()
        try container.encode(binary(endianness: .big, truncation: .none))
    }
}

public extension CellDecodable where Self: BinaryConvertible {}

// MARK: - UInt8 + CellCodable

extension UInt8: CellCodable {}

// MARK: - UInt16 + CellCodable

extension UInt16: CellCodable {}

// MARK: - UInt32 + CellCodable

extension UInt32: CellCodable {}

// MARK: - UInt64 + CellCodable

extension UInt64: CellCodable {}

// MARK: - Int8 + CellCodable

extension Int8: CellCodable {}

// MARK: - Int16 + CellCodable

extension Int16: CellCodable {}

// MARK: - Int32 + CellCodable

extension Int32: CellCodable {}

// MARK: - Int64 + CellCodable

extension Int64: CellCodable {}

// MARK: - BigInt + CellCodable

extension BigInt: CellCodable {}

// MARK: - BigUInt + CellCodable

extension BigUInt: CellCodable {}

// MARK: - Array + CellCodable

extension Array: CellCodable where Element: CellCodable {
    public func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()
        try forEach({
            try container.encode($0)
        })
    }
}
