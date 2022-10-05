//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

extension CellEncoderContainerInternal: CellEncoderContainer {
    
    func storageContainer() -> CellStorageEncodingContainer {
        self
    }
    
    func childrenContainer(
        at index: Int
    ) throws -> CellEncoderContainer {
        try children(atIndex: index)
    }
}
