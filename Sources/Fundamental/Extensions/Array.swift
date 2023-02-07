//
//  Created by Anton Spivak
//

public extension Array {
    /// Returns an array containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and index of this element and returns a
    /// transformed
    ///   value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    func mapi<T>(_ transform: (Element, Int) throws -> T) rethrows -> [T] {
        var index = 0
        return try map({
            let result = try transform($0, index)
            index += 1
            return result
        })
    }

    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    ///
    /// - Parameter body: A closure that takes an element of the sequence and its index as a
    ///   parameters
    func forEachi(_ body: (Element, Int) throws -> Void) rethrows {
        var index = 0
        try forEach({
            try body($0, index)
            index += 1
        })
    }
}
