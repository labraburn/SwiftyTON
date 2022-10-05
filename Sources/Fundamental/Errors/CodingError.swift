//
//  File.swift
//  
//
//  Created by Anton Spivak on 18.07.2022.
//

import Foundation

public struct CodingError {
    
    public let code: Code
    
    public init(
        _ code: Code
    ) {
        self.code = code
    }
}

public extension CodingError {
    
    struct Code : RawRepresentable, Hashable, Sendable {

        public let rawValue: Int
        
        public init(
            rawValue: Int
        ) {
            self.rawValue = rawValue
        }
    }
}

public extension CodingError.Code {
    
    static let cellsEmpty = CodingError.Code(rawValue: 0)
    static let maximumRootCellsOverflow = CodingError.Code(rawValue: 0)
}

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
