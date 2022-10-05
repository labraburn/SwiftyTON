//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation
import BigInt
import CryptoSwift

public struct CellEncoder {
    
    public let options: CellCodingOptions
    
    init(
        options: CellCodingOptions = .`default`
    ) {
        self.options = options
    }
    
    func encode<T>(
        _ value: T
    ) throws -> String where T: CellEncodable {
        let container = CellEncoderContainerInternal()
        try container.encode(value)
        
        let cell = container.cell
        let breadthFirstSorted = try cell.breadthFirstSort()
        
        
        let bfsCellsCount = breadthFirstSorted.cells.count
        let bfsSizeBytes = try BigInt("\(bfsCellsCount)").bytes
        
        
        
        
        
        print(container.storage)
        print(try container.storage.bytes.toHexString())
        
        
        return try container.storage.bytes.toHexString()
    }
}
