//
//  Created by Anton Spivak
//

import Buffbit

extension BinaryElement: CellCodable {
    public func encode(with encoder: CellEncoderContainer) throws {
        var container = encoder.storageContainer()
        try container.encode(self)
    }
}
