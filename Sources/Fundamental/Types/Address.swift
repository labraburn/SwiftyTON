//
//  Created by Anton Spivak
//

import Buffbit
import Foundation

// MARK: - Address

public struct Address: RawRepresentable {
    // MARK: Lifecycle

    public init?(rawValue: String) {
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

        let address: HEX = (rawValue as NSString).substring(with: match.range(at: 2))
        guard address.count == 64
        else {
            return nil
        }

        self.init(
            workchain: workchain,
            hash: Buffer(address)
        )
    }

    public init(workchain: Int8, hash: Buffer) {
        self.workchain = workchain
        self.hash = hash
    }

    // MARK: Public

    public let workchain: Int8
    public let hash: Buffer

    public var rawValue: String {
        "\(workchain):\(hash.hex)"
    }
}

// MARK: CustomStringConvertible

extension Address: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: Codable

extension Address: Codable {}

// MARK: Hashable

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
