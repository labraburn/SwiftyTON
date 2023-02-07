//
//  Created by Anton Spivak
//

extension DefaultStringInterpolation {
    mutating func appendInterpolation(_ binary: Binary) {
        appendLiteral("0b")
        appendLiteral(binary.description)
    }

    mutating func appendInterpolation(_ buffer: Buffer) {
        appendLiteral("0h")
        appendLiteral(buffer.description)
    }
}
