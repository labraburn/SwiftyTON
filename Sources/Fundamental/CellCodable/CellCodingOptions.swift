//
//  Created by Anton Spivak
//

// MARK: - CellCodingOptions

public struct CellCodingOptions {
    // MARK: Lifecycle

    public init(
        hasIndex: Bool,
        hashCRC32: Bool,
        hasCacheBits: Bool,
        topologicalOrder: TopologicalOrder,
        flags: UInt32
    ) {
        self.hasIndex = hasIndex
        self.hashCRC32 = hashCRC32
        self.hasCacheBits = hasCacheBits
        self.topologicalOrder = topologicalOrder
        self.flags = flags
    }

    // MARK: Public

    public let hasIndex: Bool
    public let hashCRC32: Bool
    public let hasCacheBits: Bool
    public let topologicalOrder: TopologicalOrder
    public let flags: UInt32
}

// MARK: CellCodingOptions.TopologicalOrder

public extension CellCodingOptions {
    enum TopologicalOrder {
        case breadthFirst
        case depthFirst
    }
}

public extension CellCodingOptions {
    static let `default` = CellCodingOptions(
        hasIndex: false,
        hashCRC32: false,
        hasCacheBits: true,
        topologicalOrder: .breadthFirst,
        flags: 0
    )
}
