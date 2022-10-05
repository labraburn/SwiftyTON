//
//  File.swift
//  
//
//  Created by Anton Spivak on 17.07.2022.
//

import Foundation
import BigInt

public protocol BytesConvertible {
    
    /// - warning: Should be presented as BigEndian
    var bytes: [UInt8] { get throws }
}

public protocol ExpressibleByBytes {
    
    /// - warning: Should be presented as BigEndian
    init(_ bytes: [UInt8]) throws
}

public typealias BytesRepresentable = BytesConvertible & ExpressibleByBytes
