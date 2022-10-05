//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

extension VariableInteger: BitsConvertible {
    
    public var bits: [Bit] {
        get throws {
            try bytes.bits
        }
    }
}
