//
//  Created by Anton Spivak
//

public protocol CellStorageEncodingContainer {
    mutating func encode<T>(_ value: T) throws where T: CellEncodable
}
