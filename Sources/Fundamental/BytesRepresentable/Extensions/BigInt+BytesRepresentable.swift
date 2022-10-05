//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation
import BigInt

extension BigInt: BytesRepresentable {
    
    public var bytes: [UInt8] {
        get throws {
            serialize().bytes
        }
    }
    
    public init(
        _ bytes: [UInt8]
    ) throws {
        self.init(Data(bytes))
    }
}

extension BigUInt: BytesRepresentable {
    
    public var bytes: [UInt8] {
        get throws {
            serialize().bytes
        }
    }
    
    public init(
        _ bytes: [UInt8]
    ) throws {
        self.init(Data(bytes))
    }
}
