//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

public extension BytesConvertible where Self: FixedWidthInteger {
    
    var bytes: [UInt8] {
        get throws {
            var bigEndian = bigEndian
            return withUnsafePointer(to: &bigEndian) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) {
                    Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<Self>.size))
                }
            }
        }
    }
}

public extension ExpressibleByBytes where Self: FixedWidthInteger {
    
    init(
        _ bytes: [UInt8]
    ) throws {
        guard bytes.count == MemoryLayout<Self>.size
        else {
            throw CellCondingError(.wrongBytesCount)
        }
        
        self = bytes.withUnsafeBytes({
            $0.load(as: Self.self)
        })
    }
}

extension UInt8: BytesRepresentable {}
extension UInt16: BytesRepresentable {}
extension UInt32: BytesRepresentable {}
extension UInt64: BytesRepresentable {}

extension Int8: BytesRepresentable {}
extension Int16: BytesRepresentable {}
extension Int32: BytesRepresentable {}
extension Int64: BytesRepresentable {}
