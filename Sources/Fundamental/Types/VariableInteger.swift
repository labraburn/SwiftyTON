//
//  File.swift
//  
//
//  Created by Anton Spivak on 05.08.2022.
//

import Foundation
import BigInt

public enum VariableInteger {
    
    case int(value: BigInt, length: Int)
    case uint(value: BigUInt, length: Int)
    
    var length: Int {
        switch self {
        case let .int(_, length):
            return length
        case let .uint(_, length):
            return length
        }
    }
    
    var isZero: Bool {
        switch self {
        case let .int(value, _):
            return value.isZero
        case let .uint(value, _):
            return value.isZero
        }
    }
}
