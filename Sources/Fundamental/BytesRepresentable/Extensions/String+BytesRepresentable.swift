//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension String: BytesRepresentable {
    
    public var bytes: [UInt8] {
        get throws {
            guard let data = data(using: .utf8)
            else {
                throw CellCondingError(.notUTF8string)
            }
            return data.bytes
        }
    }
    
    public init(
        _ bytes: [UInt8]
    ) throws {
        guard let string = String(data: Data(bytes), encoding: .utf8)
        else {
            throw CellCondingError(.notUTF8string)
        }
        self = string
    }
}
