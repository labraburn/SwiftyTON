//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension Address: CellEncodable {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        
        try container.encode([Bit.one, .zero])
        try container.encode(Bit.zero) // anycast
        try container.encode(workchain.bits)
        try container.encode(hash.bits)
    }
}

extension Optional: CellEncodable where Wrapped == Address {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        
        switch self {
        case .none:
            try container.encode([Bit.zero, .zero])
        case let .some(value):
            try container.encode(value)
        }
    }
}
