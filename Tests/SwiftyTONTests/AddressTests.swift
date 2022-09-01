//
//  Created by Anton Spivak
//

import Foundation
import XCTest

@testable import SwiftyTON

class AddressTests: XCTestCase {
    
    func testParsing() throws {
        
        // raw
        guard let concreteAddress1 = ConcreteAddress(string: "-1:fcb91a3a3816d0f7b8c2c76108b8a9bc5a6b7a55bd79f8ab101c52db29232260")
        else {
            XCTFail("Expected non-nil address")
            return
        }
        
        // bouncable, testable
        guard let concreteAddress2 = ConcreteAddress(string: "kf/8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15+KsQHFLbKSMiYIny")
        else {
            XCTFail("Expected non-nil address")
            return
        }
        
        // bouncable, testable
        guard let concreteAddress3 = ConcreteAddress(string: "kf_8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15-KsQHFLbKSMiYIny")
        else {
            XCTFail("Expected non-nil address")
            return
        }
        
        XCTAssertEqual(
            concreteAddress1.address.hash,
            concreteAddress2.address.hash
        )
        
        XCTAssertEqual(
            concreteAddress2.address.hash,
            concreteAddress3.address.hash
        )
        
        XCTAssertEqual(
            ConcreteAddress(address: concreteAddress1.address, representation: .base64url(flags: [])),
            ConcreteAddress(address: concreteAddress2.address, representation: .base64url(flags: []))
        )
        
        XCTAssertEqual(
            ConcreteAddress(address: concreteAddress2.address, representation: .base64url(flags: [])),
            ConcreteAddress(address: concreteAddress3.address, representation: .base64url(flags: []))
        )
        
        XCTAssertEqual(
            ConcreteAddress(address: concreteAddress1.address, representation: .base64url(flags: [.bounceable])),
            ConcreteAddress(address: concreteAddress2.address, representation: .base64url(flags: [.bounceable]))
        )
        
        XCTAssertEqual(
            ConcreteAddress(address: concreteAddress2.address, representation: .base64url(flags: [.testable])),
            ConcreteAddress(address: concreteAddress3.address, representation: .base64url(flags: [.testable]))
        )

        XCTAssertEqual(
            ConcreteAddress(address: concreteAddress1.address, representation: .base64(flags: [.bounceable, .testable])).description,
            "kf/8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15+KsQHFLbKSMiYIny"
        )
        
        XCTAssertEqual(
            ConcreteAddress(address: concreteAddress1.address, representation: .base64url(flags: [.bounceable, .testable])).description,
            "kf_8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15-KsQHFLbKSMiYIny"
        )
    }
}
