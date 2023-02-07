//
//  Created by Anton Spivak
//

import BigInt
import Buffer

// MARK: - VarInt

public struct VarInt: VariableInteger {
    // MARK: Lifecycle

    public init(_ value: BigInt, length: Int) {
        self.value = value
        self.length = length
    }

    // MARK: Public

    public let value: BigInt
    public let length: Int

    public var isZero: Bool {
        value.isZero
    }
}

// MARK: BufferRepresentable

extension VarInt: BufferRepresentable {}

// MARK: - VarUInt

public struct VarUInt: VariableInteger {
    // MARK: Lifecycle

    public init(_ value: BigUInt, length: Int) {
        self.value = value
        self.length = length
    }

    // MARK: Public

    public let value: BigUInt
    public let length: Int

    public var isZero: Bool {
        value.isZero
    }
}

// MARK: BufferRepresentable

extension VarUInt: BufferRepresentable {}
