//
//  File.swift
//  
//
//  Created by Anton Spivak on 16.07.2022.
//

import Foundation
import CryptoSwift

internal struct Cell {
    
    let storage: [Bit]
    let children: [Cell]
    let kind: Kind
    
    var hash: [UInt8] {
        get throws {
            try representation.bytes.sha256()
        }
    }
    
    init(
        storage: [Bit],
        children: [Cell],
        kind: Kind = .ordinary
    ) {
        self.storage = storage
        self.children = children
        self.kind = kind
    }
}

private extension Cell {
    
    var maximumDepth: [Bit] {
        get throws {
            let maximumDepth = _calculatedMaximumDepth()
            let value = Int64(floor(Double(maximumDepth) / 256)) + (maximumDepth % 256)
            return try value.bits
        }
    }

    var referencesDescriptor: [Bit] {
        get throws {
            let isExotic = kind == .exotic
            let maximumLevel = _calculatedMaximumLevel()
            let value = Int64(children.count) + (isExotic ? 1 : 0) * 8 + maximumLevel * 32
            return try value.bits
        }
    }

    var storageDescriptor: [Bit] {
        get throws {
            let value = Int64(ceil(Double(storage.count / 8))) + Int64(floor(Double(storage.count / 8)))
            return try value.bits
        }
    }

    var descriptors: [Bit] {
        get throws {
            var value = try referencesDescriptor
            value.append(contentsOf: try storageDescriptor)
            return value
        }
    }

    var representation: [Bit] {
        get throws {
            var representation = try descriptors
            representation.append(contentsOf: storage.augmented())

            try children.forEach({
                let depth = try $0.maximumDepth
                representation.append(contentsOf: depth)
            })

            try children.forEach({
                let bits = try $0.hash.bits
                representation.append(contentsOf: bits)
            })

            return representation
        }
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
    ) throws -> [Bit] where T: BitsConvertible, T: FixedWidthInteger {
        try children.reduce(
            into: try descriptors + storage.augmented(),
            { bits, children in
                let childrenIndex = try map[children.hash.toHexString()]
                guard let childrenIndex = childrenIndex
                else {
                    throw CellCondingError(.serializeError)
                }
                
                try bits.append(
                    contentsOf: childrenIndexType.init(childrenIndex).bits
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
    
    func breadthFirstSort() throws -> BreadthFirstSortResult {
        
        struct StackElement {
            
            let cell: Cell
            let hash: [UInt8]
        }
        
        var map = [String: Int]()
        var stack = [self]
        var cells = [
            StackElement(
                cell: self,
                hash: try hash
            )
        ]
        
        map[cells[0].hash.toHexString()] = 0
        
        // Add cell to cells list and to hashmap
        let append = { (node: Cell, hash: [UInt8]) in
            cells.append(StackElement(cell: node, hash: hash))
            map[hash.toHexString()] = cells.count - 1
        }
        
        // Reorder cells list and hashmap if duplicate found
        let reappend = { (index: Int) in
            // Move cell to the last position of array
            cells.append(cells.remove(at: index))
            // Change hash indexes after pulling cell from the middle of an array
            Array(cells[0 ..< index]).forEachi({ (element, i) in
                map[element.hash.toHexString()] = index + i
            })
        }
        
        // Process tree node to ordered cells list
        let process = { (node: Cell) throws in
            let hash = try node.hash
            let index = map[hash.toHexString()]
            
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
            try stack.forEach({ node in
                try node.children.forEach({ children in
                    try process(children)
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
