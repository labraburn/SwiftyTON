//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension Array: BitsConvertible where Element: BitsConvertible {

    public var bits: [Bit] {
        get throws {
            try flatMap({
                try $0.bits
            })
        }
    }
}

extension Array where Element == Bit {
    
    public var bytes: [UInt8] {
        get throws {
            var bits = self
            
            let devider = UInt8.bitWidth - (count % UInt8.bitWidth)
            if devider > 0 {
                bits.append(contentsOf: [Bit](repeating: .zero, count: devider))
            }
            
            return try stride(from: 0, to: count, by: UInt8.bitWidth).map({
                try UInt8([Bit](bits[$0 ..< ($0 + UInt8.bitWidth)]))
            })
        }
    }
}
