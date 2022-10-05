//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

extension Array: BytesConvertible where Element == BytesConvertible {

    public var bytes: [UInt8] {
        get throws {
            try flatMap({
                try $0.bytes
            })
        }
    }
}
