//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension CellEncodable where Self: BitsConvertible {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        try container.encode(bits)
    }
}

extension UInt8: CellEncodable {}
extension UInt16: CellEncodable {}
extension UInt32: CellEncodable {}
extension UInt64: CellEncodable {}

extension Int8: CellEncodable {}
extension Int16: CellEncodable {}
extension Int32: CellEncodable {}
extension Int64: CellEncodable {}

extension Array: CellEncodable where Element: CellEncodable {
    
    public func encode(
        with encoder: CellEncoderContainer
    ) throws {
        var container = encoder.storageContainer()
        try forEach({
            try container.encode($0)
        })
    }
}
