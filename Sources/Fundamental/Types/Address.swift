//
//  Created by Anton Spivak
//

import Foundation
import CryptoSwift

public struct Address: RawRepresentable {
    
    public var rawValue: String {
        "\(workchain):\(hash.toHexString())"
    }
    
    public let workchain: Int8
    public let hash: [UInt8]
    
    public init?(
        rawValue: String
    ) {
        let range = NSRange(location: 0, length: rawValue.count)
        let regex = NSRegularExpression.rawAddress
        let matches = regex.matches(in: rawValue, options: [], range: range)
        
        guard matches.count == 1
        else {
            return nil
        }
        
        let match = matches[0]
        
        guard let workchain = Int8((rawValue as NSString).substring(with: match.range(at: 1)))
        else {
            return nil
        }
        
        let address = (rawValue as NSString).substring(with: match.range(at: 2))
        guard address.count == 64
        else {
            return nil
        }
        
        self.init(
            workchain: workchain,
            hash: Array<UInt8>(hex: address)
        )
    }
    
    public init(
        workchain: Int8,
        hash: [UInt8]
    ) {
        self.workchain = workchain
        self.hash = hash
    }
}

extension Address: CustomStringConvertible {
    
    public var description: String {
        rawValue
    }
}

extension Address: Codable {}
extension Address: Hashable {}

private extension NSRegularExpression {
    
    static var rawAddress: NSRegularExpression = {
        let pattern = "^(0|-1):([a-f0-9]{64}|[A-F0-9]{64})$"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern)
        else {
            fatalError("Can't compose `NSRegularExpression` for pattern: \(pattern)")
        }
        return regularExpression
    }()
}
