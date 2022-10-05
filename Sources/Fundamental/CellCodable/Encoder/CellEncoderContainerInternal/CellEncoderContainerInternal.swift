//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

internal class CellEncoderContainerInternal {
    
    let capacity: Int
    
    private(set) var storage: [Bit]
    private(set) var children: [CellEncoderContainerInternal]
    
    var cell: Cell {
        Cell(storage: storage, children: children.map(\.cell))
    }
    
    init(
        capacity: Int = 1023
    ) {
        self.capacity = capacity
        self.storage = []
        self.children = []
    }
    
    func append(
        _ storage: [Bit]
    ) throws {
        self.storage.append(contentsOf: storage)
        guard storage.count <= capacity
        else {
            throw CellCondingError(.storageOverflow)
        }
    }
    
    func children(
        atIndex index: Int
    ) throws -> CellEncoderContainerInternal {
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
