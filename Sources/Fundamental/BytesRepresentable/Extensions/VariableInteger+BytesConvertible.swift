//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

extension VariableInteger: BytesConvertible {
    
    public var bytes: [UInt8] {
        get throws {
            switch self {
            case let .int(value, _):
                return try value.bytes
            case let .uint(value, _):
                return try value.bytes
            }
        }
    }
}
