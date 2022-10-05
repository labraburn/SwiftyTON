//
//  File.swift
//  
//
//  Created by Anton Spivak on 16.07.2022.
//

import Foundation

public enum Bit: Int  {
    
    case one = 1
    case zero = 0
}

extension Bit: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

public extension Array where Element == Bit {
    
    enum AugmentingDivider: Int {
        
        case four = 4
        case eight = 8
    }
    
    /// Augment bits with initial `Bit.one` and leading 0 to be divisible by 8 or 4 without remainder.
    func augmented(
        to divider: AugmentingDivider = .eight
    ) -> [Element] {
        var result = self
        
        let damount = count % divider.rawValue
        let appendix = [Element](repeating: .zero, count: divider.rawValue - damount).mapi({
            $1 == 0 ? Element.one : .zero
        })
        
        if !appendix.isEmpty && appendix.count != divider.rawValue {
            result.append(contentsOf: appendix)
        }
        
        return result
    }
    
    /// Remove previously augmented bits
    func rollback() -> [Element] {
        let index = lastIndex(of: .one)
        guard let index = index,
              index > count - 8
        else {
            return Array(self)
        }
        return Array(self[0 ..< index])
    }
    
    var description: String {
        reduce(into: "", {
            $0 += $1.description
        })
    }
}

//extension Array: BytesConvertible where Element == Bit {
//    
//    public var bytes: [UInt8] {
//        stride(from: 0, to: count, by: 8).map({
//            UInt8(Array(self[$0 ..< Swift.min($0 + 8, count)]))
//        })
//    }
//}
//
//extension Array: BitsConvertible where Element == UInt8 {
//    
//    public var bits: [Bit] {
//        reduce(into: [Bit](), { $0.append(contentsOf: $1.bits) })
//    }
//}

