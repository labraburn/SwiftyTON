//
//  Created by Anton Spivak
//

import Buffbit

internal class CellEncoderContainerInternal {
    // MARK: Lifecycle

    init(capacity: Int = 1023) {
        self.capacity = capacity
        self.storage = []
        self.children = []
    }

    // MARK: Internal

    let capacity: Int

    private(set) var storage: [BinaryElement]
    private(set) var children: [CellEncoderContainerInternal]

    var cell: Cell {
        Cell(storage: storage, children: children.map(\.cell))
    }

    func append(_ storage: [BinaryElement]) throws {
        self.storage.append(contentsOf: storage)
        guard storage.count <= capacity
        else {
            throw CellCondingError(.storageOverflow)
        }
    }

    func children(atIndex index: Int) throws -> CellEncoderContainerInternal {
        guard index < 4
        else {
            throw CellCondingError(.childrenOverflow)
        }

        if index < children.count {
            return children[index]
        } else {
            let children = CellEncoderContainerInternal(capacity: capacity)
            self.children[index] = children
            return children
        }
    }
}
