//
//  Created by Anton Spivak
//

// MARK: - CellEncodable

public protocol CellEncodable {
    func encode(with encoder: CellEncoderContainer) throws
}

// MARK: - CellDecodable

public protocol CellDecodable {}

public typealias CellCodable = CellEncodable & CellDecodable
