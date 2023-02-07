//
//  Created by Anton Spivak
//

public typealias Buffer = [BufferElement]

public extension Buffer {
    var description: HEX {
        map({ $0.description }).joined()
    }
}

public extension Buffer {
    var debugDescription: HEX {
        description
    }
}

public extension Buffer {
    var playgroundDescription: Any {
        description
    }
}
