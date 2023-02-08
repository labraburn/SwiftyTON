//
//  Created by Anton Spivak
//

import Buffbit
import CryptoKit
import Foundation

internal extension Digest {
    var buffer: Buffer { Array(makeIterator()) }
    var data: Data { Data(buffer) }
}

internal extension SHA256 {
    /// Computes a digest of the buffer.
    ///
    /// - Parameter buffer: The `Buffer` to be hashed
    /// - Returns: The computed buffer of digest
    static func hash(_ buffer: Buffer) -> Buffer {
        let data = Data(buffer)
        return SHA256.hash(data: data).buffer
    }
}

internal extension Buffer {
    /// Computes a digest of the buffer.
    var sha256: Buffer {
        SHA256.hash(self)
    }
}
