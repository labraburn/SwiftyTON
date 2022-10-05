//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

public protocol CellEncoderContainer {
    
    func storageContainer() -> CellStorageEncodingContainer
    
    func childrenContainer(
        at index: Int
    ) throws -> CellEncoderContainer
}

internal class _CellEncoderContainer {
    
    let capacity: Int
    
    private(set) var storage: [Bit]
    private(set) var children: [_CellEncoderContainer]
    
    init(
        capacity: Int = 1023
    ) {
        self.capacity = capacity
        self.storage = []
        self.children = []
    }
}

extension _CellEncoderContainer: CellEncoderContainer {
    
    func storageContainer() -> CellStorageEncodingContainer {
        self
    }
    
    func childrenContainer(
        at index: Int
    ) throws -> CellEncoderContainer {
        guard index < 4
        else {
            throw CellCondingError(.childrenOverflow)
        }
        
        let childrenContainer: _CellEncoderContainer
        if index < children.count  {
            childrenContainer = children[index]
        } else {
            childrenContainer = _CellEncoderContainer(capacity: capacity)
            children[index] = childrenContainer
        }
        
        return childrenContainer
    }
}

extension _CellEncoderContainer: CellStorageEncodingContainer {
    
    func encode<T>(
        _ value: T
    ) throws where T : CellEncodable {
        if let value = value as? Bit {
            storage.append(value)
        } else if let value = value as? [Bit] {
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
