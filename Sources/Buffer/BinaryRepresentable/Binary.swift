//
//  Created by Anton Spivak
//

public typealias Binary = [BinaryElement]

public extension Binary {
    var description: String {
        reduce(into: "", { $0 += $1.description })
    }
}

public extension Binary {
    var debugDescription: String {
        description
    }
}

public extension Binary {
    var playgroundDescription: Any {
        description
    }
}
