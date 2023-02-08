//
//  Created by Anton Spivak
//

import Buffbit

// MARK: - CellEncoderContainer

public protocol CellEncoderContainer {
    func storageContainer() -> CellStorageEncodingContainer
    func childrenContainer(at index: Int) throws -> CellEncoderContainer
}

// MARK: - _CellEncoderContainer

internal class _CellEncoderContainer {
    // MARK: Lifecycle

    init(capacity: Int = 1023) {
        self.capacity = capacity
        self.storage = []
        self.children = []
    }

    // MARK: Internal

    let capacity: Int

    private(set) var storage: [BinaryElement]
    private(set) var children: [_CellEncoderContainer]
}

// MARK: CellEncoderContainer

extension _CellEncoderContainer: CellEncoderContainer {
    func storageContainer() -> CellStorageEncodingContainer {
        self
    }

    func childrenContainer(at index: Int) throws -> CellEncoderContainer {
        guard index < 4
        else {
            throw CellCondingError(.childrenOverflow)
        }

        let childrenContainer: _CellEncoderContainer
        if index < children.count {
            childrenContainer = children[index]
        } else {
            childrenContainer = _CellEncoderContainer(capacity: capacity)
            children[index] = childrenContainer
        }

        return childrenContainer
    }
}

// MARK: CellStorageEncodingContainer

extension _CellEncoderContainer: CellStorageEncodingContainer {
    func encode<T>(_ value: T) throws where T: CellEncodable {
        if let value = value as? BinaryElement {
            storage.append(value)
        } else if let value = value as? [BinaryElement] {
            storage.append(contentsOf: value)
        } else {
            try value.encode(with: self)
        }

        guard storage.count <= capacity
        else {
            throw CellCondingError(.storageOverflow)
        }
    }
}
