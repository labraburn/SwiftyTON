//
//  Created by Anton Spivak
//

// MARK: - BinaryElement

public enum BinaryElement {
    case one
    case zero
}

// MARK: RawRepresentable

extension BinaryElement: RawRepresentable {
    public init(rawValue: Bool) {
        switch rawValue {
        case true:
            self = .one
        case false:
            self = .zero
        }
    }

    public var rawValue: Bool {
        switch self {
        case .one:
            return true
        case .zero:
            return false
        }
    }
}

// MARK: CustomStringConvertible

extension BinaryElement: CustomStringConvertible {
    public var description: String {
        switch self {
        case .zero:
            return "0"
        case .one:
            return "1"
        }
    }
}

// MARK: CustomDebugStringConvertible

extension BinaryElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        description
    }
}

// MARK: CustomPlaygroundDisplayConvertible

extension BinaryElement: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        description
    }
}
