//
//  Created by Anton Spivak
//

public typealias HEX = String

public extension Buffer {
    init(_ hex: HEX) {
        var startIndex = hex.startIndex
        self = (0 ..< hex.count / 2).compactMap { _ in
            let endIndex = hex.index(after: startIndex)
            defer {
                startIndex = hex.index(after: endIndex)
            }
            return BufferElement(hex[startIndex ... endIndex], radix: 16)
        }
    }

    var hex: HEX {
        description
    }
}
