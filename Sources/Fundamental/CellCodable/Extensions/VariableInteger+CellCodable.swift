//
//  Created by Anton Spivak
//

import Buffer
import Foundation

// MARK: - VarInt + CellEncodable

public extension VariableInteger where Value: BufferRepresentable {
    func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()

        let count = Int(ceil(log2(Double(length))))
        if isZero {
            try container.encode(Binary(repeating: .zero, count: count))
        } else {
            let buffer = buffer()
            let binary = buffer.binary()

            let slice = Int64(buffer.count).binary().suffix(count)

            try container.encode(Array(slice))
            try container.encode(binary)
        }
    }
}

// MARK: - VarInt + CellCodable

extension VarInt: CellCodable {}

// MARK: - VarUInt + CellCodable

extension VarUInt: CellCodable {}
