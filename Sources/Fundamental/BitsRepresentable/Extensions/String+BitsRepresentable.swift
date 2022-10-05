//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension String: BitsRepresentable {
    
    public var bits: [Bit] {
        get throws {
            try bytes.bits
        }
    }
    
    public init(
        _ bits: [Bit]
    ) throws {
        try self.init(
            bits.bytes
        )
    }
}
