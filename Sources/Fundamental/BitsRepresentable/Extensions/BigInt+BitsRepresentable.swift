//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation
import BigInt

extension BigInt: BitsRepresentable {
    
    public var bits: [Bit] {
        get throws {
            try serialize().bytes.bits
        }
    }
    
    public init(
        _ bits: [Bit]
    ) throws {
        self.init(
            Data(try bits.bytes)
        )
    }
}

extension BigUInt: BitsRepresentable {
    
    public var bits: [Bit] {
        get throws {
            try serialize().bytes.bits
        }
    }
    
    public init(
        _ bits: [Bit]
    ) throws {
        self.init(
            Data(try bits.bytes)
        )
    }
}
