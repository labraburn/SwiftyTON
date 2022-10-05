//
//  File.swift
//  
//
//  Created by Anton Spivak on 17.07.2022.
//

import Foundation
import BigInt

public protocol BitsConvertible {
    
    /// - warning: Should be presented as BigEndian
    var bits: [Bit] { get throws }
}

public protocol ExpressibleByBits {
    
    /// - warning: Should be presented as BigEndian
    init(_ bits: [Bit]) throws
}

public typealias BitsRepresentable = BitsConvertible & ExpressibleByBits
