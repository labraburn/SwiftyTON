//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation
import BigInt

extension Currency: CellEncodable {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        try container.encode(_variableInteger)
        
        let new = try encoder.childrenContainer(at: 0)
    }
    
    private var _variableInteger: VariableInteger {
        VariableInteger.uint(
            value: BigUInt(value),
            length: 16
        )
    }
}
