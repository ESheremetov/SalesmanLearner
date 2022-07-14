//
//  CompuatableExtension.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 20.06.2022.
//

import Foundation


protocol Computable {
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    
    static func -= (lhs: inout Self, rhs: Self)
    static func += (lhs: inout Self, rhs: Self)
}


extension Double: Computable {}
extension Int: Computable {}
extension Float: Computable {}

extension String: Computable {
    static func -= (lhs: inout String, rhs: String) {
        lhs = lhs.replacingOccurrences(of: rhs, with: "")
    }
    
    static func += (lhs: inout String, rhs: String) {
        lhs = "\(lhs)\(rhs)"
    }
    
    static func - (lhs: String, rhs: String) -> String {
        return lhs.replacingOccurrences(of: rhs, with: "")
    }
    
    static func + (lhs: String, rhs: String) -> String {
        return "\(lhs)\(rhs)"
    }
}
