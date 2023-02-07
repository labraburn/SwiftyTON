//
//  Created by Anton Spivak
//

import Foundation

public typealias BufferElement = UInt8

// MARK: CustomStringConvertible

public extension BufferElement {
    var description: HEX {
        String(format: "%02X", self)
    }
}

// MARK: CustomDebugStringConvertible

extension BufferElement: CustomDebugStringConvertible {
    public var debugDescription: HEX {
        description
    }
}

// MARK: CustomPlaygroundDisplayConvertible

extension BufferElement: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        description
    }
}
