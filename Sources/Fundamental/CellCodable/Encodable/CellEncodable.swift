//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.08.2022.
//

import Foundation

public protocol CellEncodable {
    
    func encode(
        with encoder: CellEncoderContainer
    ) throws
}
