//
//  Created by Anton Spivak
//

import Buffer

// MARK: - Address + CellCodable

extension Address: CellCodable {
    public func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()

        try container.encode([BinaryElement.one, .zero])
        try container.encode(BinaryElement.zero) // anycast
        try container.encode(workchain.binary())
        try container.encode(hash.binary())
    }
}

// MARK: - Optional + CellCodable

extension Optional: CellCodable where Wrapped == Address {
    public func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()

        switch self {
        case .none:
            try container.encode([BinaryElement.zero, .zero])
        case let .some(value):
            try container.encode(value)
        }
    }
}
