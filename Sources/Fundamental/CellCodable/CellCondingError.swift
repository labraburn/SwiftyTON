//
//  Created by Anton Spivak
//

import Foundation

// MARK: - CellCondingError

public struct CellCondingError {
    // MARK: Lifecycle

    public init(_ code: Code) {
        self.code = code
    }

    // MARK: Public

    public let code: Code
}

// MARK: CellCondingError.Code

public extension CellCondingError {
    struct Code: RawRepresentable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public let rawValue: Int
    }
}

public extension CellCondingError.Code {
    static let storageOverflow = CellCondingError.Code(rawValue: 0)
    static let childrenOverflow = CellCondingError.Code(rawValue: 1)
    static let byteBitsCount = CellCondingError.Code(rawValue: 2)
    static let notUTF8string = CellCondingError.Code(rawValue: 3)
    static let wrongBytesCount = CellCondingError.Code(rawValue: 4)
    static let serializeError = CellCondingError.Code(rawValue: 5)
}

// MARK: - CellCondingError + LocalizedError

extension CellCondingError: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .storageOverflow:
            return "Cell bits storage overflow."
        case .childrenOverflow:
            return "Cell children references overflow."
        case .byteBitsCount:
            return "Byte can be initialized only with 8 bits."
        case .notUTF8string:
            return "Can't encode/decode UTF8 string."
        case .wrongBytesCount:
            return "Bytes count mismatch."
        case .serializeError:
            return "Can't serialize cell."
        default:
            return nil
        }
    }
}
