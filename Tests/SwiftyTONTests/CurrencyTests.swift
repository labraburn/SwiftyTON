//
//  Created by Anton Spivak
//

import Foundation
import XCTest

@testable import SwiftyTON

class CurrencyTests: XCTestCase {
    
    func testParsing() throws {
        XCTAssertEqual(Currency(value: 1_000_000_000), CurrencyFormatter.currecny(from: "1"))
        XCTAssertEqual(Currency(value: 0_100_000_000), CurrencyFormatter.currecny(from: "0.1"))
        XCTAssertEqual(Currency(value: 0_000_100_000), CurrencyFormatter.currecny(from: "0,0001"))
        XCTAssertEqual(Currency(value: 0_000_000_100), CurrencyFormatter.currecny(from: "0.0000001"))
    }
}
