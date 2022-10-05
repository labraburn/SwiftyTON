//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

public extension BitsConvertible where Self: BytesConvertible {
    
    var bits: [Bit] {
        get throws {
            try bytes.bits
        }
    }
}

public extension ExpressibleByBits where Self: ExpressibleByBytes {
    
    init(
        _ bits: [Bit]
    ) throws {
        try self.init(
            bits.bytes
        )
    }
}

extension UInt8: BitsRepresentable {
    
    public var bits: [Bit] {
        get throws {
            var byte = self
            var bits = [Bit](repeating: .zero, count: Self.bitWidth)
            
            for i in 0 ..< Self.bitWidth {
                let bit = byte & 0x01
                byte >>= 1
                
                guard bit != 0
                else {
                    continue
                }
                
                bits[i] = .one
            }
            
            return bits.reversed()
        }
    }
    
    public init(
        _ bits: [Bit]
    ) throws {
        guard bits.count == Self.bitWidth
        else {
            throw CellCondingError(.byteBitsCount)
        }
        
        var value = UInt8(0)
        stride(from: 0, to: Self.bitWidth, by: 1).forEach({
            guard bits[$0] == .one
            else {
                return
            }
            
            value += 1 << (Self.bitWidth - $0 - 1)
        })
        
        self = value
    }
}

extension UInt16: BitsRepresentable {}
extension UInt32: BitsRepresentable {}
extension UInt64: BitsRepresentable {}

extension Int8: BitsRepresentable {}
extension Int16: BitsRepresentable {}
extension Int32: BitsRepresentable {}
extension Int64: BitsRepresentable {}
