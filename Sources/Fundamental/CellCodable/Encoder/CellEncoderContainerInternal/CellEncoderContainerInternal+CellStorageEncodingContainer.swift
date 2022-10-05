//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

extension CellEncoderContainerInternal: CellStorageEncodingContainer {
    
    func encode<T>(
        _ value: T
    ) throws where T : CellEncodable {
        if let value = value as? Bit {
            try append([value])
        } else if let value = value as? [Bit] {
            try append(value)
        } else {
            try value.encode(with: self)
        }
    }
}
