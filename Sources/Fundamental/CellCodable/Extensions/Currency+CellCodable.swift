//
//  Created by Anton Spivak
//

import BigInt
import Foundation

extension Currency: CellCodable {
    public func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()

        let value = VarUInt(BigUInt(value), length: 16)
        try container.encode(value)
    }
}
