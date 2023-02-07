//
//  Created by Anton Spivak
//

internal extension Array {
    func chunked(withSliceSize size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
