//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension Bit: CellEncodable {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        try container.encode(self)
    }
}
