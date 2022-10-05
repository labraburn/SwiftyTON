//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation
import XCTest

@testable import Fundamental

class CellEncodableTests: XCTestCase {
    
    struct TestingValue: CellEncodable {
        
        func encode(
            with encoder: CellEncodingContainer
        ) throws {
            var container = encoder
            
//            try container.encode([Bit.zero, .zero, .one])
//            try container.encode(UInt16(16))
            try container.encode(VariableInteger.uint(value: "36567853497567834657892", length: 256))
        }
    }
    
    func testEncoding() throws {
        
        let value = TestingValue()
        
        let encoder = CellEncoder()
        let encoded = try encoder.encode(value)
        
        print(encoded)
        
//        XCTAssertEqual(
//            concreteAddress1.address.hash,
//            concreteAddress2.address.hash
//        )
    }
}

