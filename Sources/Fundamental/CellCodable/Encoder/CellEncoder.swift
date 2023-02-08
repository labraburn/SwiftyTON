//
//  Created by Anton Spivak
//

import BigInt
import Buffbit

public struct CellEncoder {
    // MARK: Lifecycle

    public init(options: CellCodingOptions = .default) {
        self.options = options
    }

    // MARK: Public

    public let options: CellCodingOptions

    public func encode<T>(_ value: T) throws -> HEX where T: CellEncodable {
        let container = CellEncoderContainerInternal()
        try container.encode(value)

        let cell = container.cell
        let buffer = Buffer(binary: cell.storage, endianness: .big)

        return buffer.hex
    }
}
