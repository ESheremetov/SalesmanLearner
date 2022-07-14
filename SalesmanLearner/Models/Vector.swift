//
//  Vector.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 20.06.2022.
//

import Foundation


protocol VectorSubscriptableProtocol: AnyObject {
    associatedtype Element
    associatedtype Index
    
    var count: Int { get }
    subscript(position: Index) -> Element { get set }
    
    func remove(at index: Index)
    
    func min() -> Element?
    func max() -> Element?
    
    func minIndex() -> Index?
    func maxIndex() -> Index?
    
    func min(except index: Index) -> Element?
    func max(except index: Index) -> Element?
    
    func minIndex(except index: Index) -> Index?
    func maxIndex(except index: Index) -> Index?
}

protocol VectorProtocol: VectorSubscriptableProtocol {
    associatedtype Element
    associatedtype Index
    
    var indexes: Array<Index> { get }
    var values: Array<Element> { get set }
        
    func copy() -> Self
}


final class Vector<T: Comparable, K: Equatable> : VectorProtocol where T: Computable {
    
    var indexes: Array<K> = []
    var values: Array<T> = []
    
    required init(values: Array<T>, indexes: Array<K> = []) {
        self.values = values
        self.indexes = indexes.isEmpty ? Array(1...self.values.count) as! Array<K> : indexes
    }
}

extension Vector {
    func copy() -> Vector {
        let copyVector = Vector(values: self.values, indexes: self.indexes)
        return copyVector
    }
}

extension Vector {
    
    var count: Int {
        return self.values.count
    }
    
    subscript(position: K) -> T {
        get {
            guard let index = self.indexes.firstIndex(of: position) else { fatalError("Unkown index: \(position)") }
            return self.values[index]
        }
        
        set {
            guard let index = self.indexes.firstIndex(of: position) else { fatalError("Unkown index: \(position)") }
            self.values[index] = newValue
        }
    }
    
    func min() -> T? {
        return self.values.min()
    }
    
    func max() -> T? {
        return self.values.max()
    }
    
    func min(except index: K) -> T? {
        guard let index = self.indexes.firstIndex(of: index) else { return nil }
        var valuesCopy = self.values
        valuesCopy.remove(at: index)
        return valuesCopy.min()
    }
    
    func max(except index: K) -> T? {
        guard let index = self.indexes.firstIndex(of: index) else { return nil }
        var valuesCopy = self.values
        valuesCopy.remove(at: index)
        return valuesCopy.max()
    }
    
    func minIndex(except index: K) -> K? {
        guard let index = self.indexes.firstIndex(of: index) else { return nil }
        
        var valuesCopy = self.values
        valuesCopy.remove(at: index)
        
        var indexCopy = self.indexes
        indexCopy.remove(at: index)
        
        guard let minValue = valuesCopy.min() else { return nil }
        guard let minIndex = valuesCopy.firstIndex(of: minValue) else { return nil }
        return indexCopy[minIndex]
    }
    
    func maxIndex(except index: K) -> K? {
        guard let index = self.indexes.firstIndex(of: index) else { return nil }
        
        var valuesCopy = self.values
        valuesCopy.remove(at: index)
        
        var indexCopy = self.indexes
        indexCopy.remove(at: index)
        
        guard let maxValue = valuesCopy.max() else { return nil }
        guard let maxIndex = valuesCopy.firstIndex(of: maxValue) else { return nil }
        return indexCopy[maxIndex]
    }
    
    func minIndex() -> K? {
        guard let minValue = self.min() else { return nil }
        guard let minIndex = self.values.firstIndex(of: minValue) else { return nil }
        return self.indexes[minIndex]
    }
    
    func maxIndex() -> K? {
        guard let maxValue = self.max() else { return nil }
        guard let maxIndex = self.values.firstIndex(of: maxValue) else { return nil }
        return self.indexes[maxIndex]
    }
    
    func remove(at index: K) {
        guard let i = self.indexes.firstIndex(of: index) else { return }
        self.values.remove(at: i)
        self.indexes.remove(at: i)
    }
}

extension Vector {
    
    static public func - (lhs: Vector, rhs: T) -> Vector {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] - rhs
        }
        return lhs
    }
    
    static public func + (lhs: Vector, rhs: T) -> Vector {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] + rhs
        }
        return lhs
    }
    
    static public func -= (lhs: inout Vector, rhs: T) {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] - rhs
        }
    }
    
    static public func += (lhs: inout Vector, rhs: T) {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] + rhs
        }
    }
    
    static public func - (lhs: Vector, rhs: Vector) -> Vector {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] - rhs.values[i]
        }
        return lhs
    }
    
    static public func + (lhs: Vector, rhs: Vector) -> Vector {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] + rhs.values[i]
        }
        return lhs
    }
    
    static public func -= (lhs: inout Vector, rhs: Vector) {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] - rhs.values[i]
        }
    }
    
    static public func += (lhs: inout Vector, rhs: Vector) {
        for i in 0..<lhs.values.count {
            lhs.values[i] = lhs.values[i] + rhs.values[i]
        }
    }
}

extension Vector: CustomStringConvertible {
    var description: String {
        var desc: String = ""
        for v in self.values {
            desc += " \(v)"
        }
        return desc
    }
}
