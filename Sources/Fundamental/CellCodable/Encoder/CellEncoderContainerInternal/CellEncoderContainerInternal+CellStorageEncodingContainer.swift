//
//  Created by Anton Spivak
//

import Buffbit

extension CellEncoderContainerInternal: CellStorageEncodingContainer {
    func encode<T>(_ value: T) throws where T: CellEncodable {
        if let value = value as? BinaryElement {
            try append([value])
        } else if let value = value as? [BinaryElement] {
            try append(value)
        } else {
            try value.encode(with: self)
        }
    }
}
