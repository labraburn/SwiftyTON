//
//  Created by Anton Spivak
//

extension CellEncoderContainerInternal: CellEncoderContainer {
    func storageContainer() -> CellStorageEncodingContainer {
        self
    }

    func childrenContainer(at index: Int) throws -> CellEncoderContainer {
        try children(atIndex: index)
    }
}
