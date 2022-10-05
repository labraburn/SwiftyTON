//
//  File.swift
//  
//
//  Created by Anton Spivak on 07.08.2022.
//

import Foundation

public protocol CellStorageEncodingContainer {
    
    mutating func encode<T>(
        _ value: T
    ) throws where T: CellEncodable
}
