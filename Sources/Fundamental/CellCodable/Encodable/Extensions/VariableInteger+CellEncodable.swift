//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension VariableInteger: CellEncodable {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        
        let count = Int(ceil(log2(Double(length))))
        if isZero {
            try container.encode([Bit](repeating: .zero, count: count))
        } else {
            let slice = try Int64(bytes.count).bits.suffix(count)
            try container.encode(Array(slice))
            try container.encode(bits)
        }
    }
}
