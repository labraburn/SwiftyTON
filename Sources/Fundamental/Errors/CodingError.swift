//
//  Created by Anton Spivak
//

import Foundation

// MARK: - CodingError

public struct CodingError {
    // MARK: Lifecycle

    public init(_ code: Code) {
        self.code = code
    }

    // MARK: Public

    public let code: Code
}

// MARK: CodingError.Code

public extension CodingError {
    struct Code: RawRepresentable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public let rawValue: Int
    }
}

public extension CodingError.Code {
    static let cellsEmpty = CodingError.Code(rawValue: 0)
    static let maximumRootCellsOverflow = CodingError.Code(rawValue: 0)
}

// MARK: - CodingError + LocalizedError

extension CodingError: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .maximumRootCellsOverflow:
            return "Maximum cells allowed as root for encoding: `4`"
        case .cellsEmpty:
            return "Can't encode empty cells array"
        default:
            return nil
        }
    }
}
