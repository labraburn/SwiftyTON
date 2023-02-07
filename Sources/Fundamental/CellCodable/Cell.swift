//
//  Created by Anton Spivak
//

import Buffer
import Foundation

// MARK: - Cell

internal struct Cell {
    // MARK: Lifecycle

    init(storage: Binary, children: [Cell], kind: Kind = .ordinary) {
        self.storage = storage
        self.children = children
        self.kind = kind
    }

    // MARK: Internal

    let storage: Binary
    let children: [Cell]
    let kind: Kind

    var hash: Buffer {
        Buffer(binary: representation, endianness: .big).sha256
    }
}

private extension Cell {
    var maximumDepth: [BinaryElement] {
        let maximumDepth = _calculatedMaximumDepth()
        let value = Int64(floor(Double(maximumDepth) / 256)) + (maximumDepth % 256)
        return value.binary()
    }

    var referencesDescriptor: [BinaryElement] {
        let isExotic = kind == .exotic
        let maximumLevel = _calculatedMaximumLevel()
        let value = Int64(children.count) + (isExotic ? 1 : 0) * 8 + maximumLevel * 32
        return value.binary()
    }

    var storageDescriptor: [BinaryElement] {
        let value = Int64(ceil(Double(storage.count / 8))) + Int64(floor(Double(storage.count / 8)))
        return value.binary()
    }

    var descriptors: [BinaryElement] {
        var value = referencesDescriptor
        value.append(contentsOf: storageDescriptor)
        return value
    }

    var representation: [BinaryElement] {
        var representation = descriptors
        representation.append(contentsOf: storage.augmented())

        children.forEach({
            let depth = $0.maximumDepth
            representation.append(contentsOf: depth)
        })

        children.forEach({
            let bits = $0.hash.binary()
            representation.append(contentsOf: bits)
        })

        return representation
    }

    func _calculatedMaximumDepth() -> Int64 {
        let _maximumDepth = children.reduce(into: Int64(0), { result, cell in
            let depth = cell._calculatedMaximumDepth()
            result = depth > result ? depth : result
        })
        return children.count > 0 ? _maximumDepth + 1 : _maximumDepth
    }

    func _calculatedMaximumLevel() -> Int64 {
        switch kind {
        case .ordinary:
            return 0
        case .exotic:
            // TODO: write code for exotic cells support
            return 0
        }
    }
}

internal extension Cell {
    func serialize<T>(
        with map: [HEX: Int],
        childrenIndexType: T.Type
    ) throws -> [BinaryElement] where T: BinaryConvertible, T: FixedWidthInteger {
        try children.reduce(
            into: descriptors + storage.augmented(),
            { bits, children in
                let childrenIndex = map[children.hash.hex]
                guard let childrenIndex = childrenIndex
                else {
                    throw CellCondingError(.serializeError)
                }

                bits.append(
                    contentsOf: childrenIndexType.init(childrenIndex).binary(
                        endianness: .big,
                        truncation: .none
                    )
                )
            }
        )
    }
}

internal extension Cell {
    struct BreadthFirstSortResult {
        let cells: [Cell]
        let map: [String: Int]
    }

    func breadthFirstSort() -> BreadthFirstSortResult {
        struct StackElement {
            let cell: Cell
            let hash: [UInt8]
        }

        var map = [String: Int]()
        var stack = [self]
        var cells = [
            StackElement(
                cell: self,
                hash: hash
            ),
        ]

        map[cells[0].hash.hex] = 0

        // Add cell to cells list and to hashmap
        let append = { (node: Cell, hash: [UInt8]) in
            cells.append(StackElement(cell: node, hash: hash))
            map[hash.hex] = cells.count - 1
        }

        // Reorder cells list and hashmap if duplicate found
        let reappend = { (index: Int) in
            // Move cell to the last position of array
            cells.append(cells.remove(at: index))
            // Change hash indexes after pulling cell from the middle of an array
            Array(cells[0 ..< index]).forEachi({ element, i in
                map[element.hash.hex] = index + i
            })
        }

        // Process tree node to ordered cells list
        let process = { (node: Cell) in
            let hash = node.hash
            let index = map[hash.hex]

            stack.append(node)

            if let index = index {
                reappend(index)
            } else {
                append(node, hash)
            }
        }

        // Loop through multi-tree and make breadth-first search till last node
        while !stack.isEmpty {
            let count = stack.count
            stack.forEach({ node in
                node.children.forEach({ children in
                    process(children)
                })
            })
            stack.removeFirst(count)
        }

        return BreadthFirstSortResult(
            cells: cells.map({
                $0.cell
            }),
            map: map
        )
    }
}

internal extension Binary {
    enum AugmentingDivider: Int {
        case four = 4
        case eight = 8
    }

    /// Augment bits with initial `BinaryElement.one` and leading 0 to be divisible by 8 or 4
    /// without remainder.
    func augmented(to divider: AugmentingDivider = .eight) -> [Element] {
        var result = self

        let damount = count % divider.rawValue
        let appendix = [Element](repeating: .zero, count: divider.rawValue - damount).mapi({
            $1 == 0 ? Element.one : .zero
        })

        if !appendix.isEmpty && appendix.count != divider.rawValue {
            result.append(contentsOf: appendix)
        }

        return result
    }

    /// Remove previously augmented bits
    func rollback() -> [Element] {
        let index = lastIndex(of: .one)
        guard let index = index,
              index > count - 8
        else {
            return Array(self)
        }
        return Array(self[0 ..< index])
    }
}
