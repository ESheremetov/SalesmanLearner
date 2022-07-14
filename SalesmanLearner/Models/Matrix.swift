//
//  Matrix.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 20.06.2022.
//

import Foundation


enum Axis {
    case rows
    case columns
}

class Matrix<T: Comparable, K: Equatable> where T: Computable {
    
    typealias MatrixType = Array<Array<T>>
    
    var rows: Array<Vector<T, K>> = []
    
    var columns: Array<Vector<T, K>> {
        var columnsVectors: Array<Vector<T, K>> = []
        guard rows.isEmpty == false else { return columnsVectors }
        for i in rows[0].indexes {
            var vectorsValues: Array<T> = []
            for j in 0..<rows.count {
                vectorsValues.append(rows[j][i])
            }
            let vector = Vector(values: vectorsValues, indexes: self.rowIndexes)
            columnsVectors.append(vector)
        }
        return columnsVectors
    }
    
    var size: (Int, Int) {
        return (self.rows.count, self.columns.count)
    }
    
    var rowIndexes: Array<K> = []
    var columnIndexes: Array<K> = []
    
    var T: Matrix {
        let newMatrix = self.copy()
        newMatrix.rows = self.columns.map { $0.copy() }
        
        newMatrix.rowIndexes = self.columnIndexes
        newMatrix.columnIndexes = self.rowIndexes
        
        return newMatrix
    }
    
    convenience init(values: MatrixType, rowIndexes: Array<K> = [], columnIndexes: Array<K> = []) {
        self.init()
        
        self.rowIndexes = rowIndexes.isEmpty ? Array(1...values.count) as! Array<K> : rowIndexes
        self.columnIndexes = columnIndexes.isEmpty ? Array(1...values[0].count) as! Array<K> : columnIndexes
        
        for row in values {
            let row = Vector(values: row, indexes: self.rowIndexes)
            rows.append(row)
        }
    }
}

extension Matrix {
    func copy() -> Matrix {
        let newMatrix = Matrix()
        newMatrix.rows = self.rows.map { $0.copy() }
        newMatrix.rowIndexes = self.rowIndexes
        newMatrix.columnIndexes = self.columnIndexes
        return newMatrix
    }
}


extension Matrix {
    subscript(position: K) -> Vector<T, K> {
        get {
            guard let index = self.rowIndexes.firstIndex(of: position) else { fatalError("Unkown index: \(position)") }
            return self.rows[index]
        }

        set {
            guard let index = self.rowIndexes.firstIndex(of: position) else { fatalError("Unkown index: \(position)") }
            self.rows[index] = newValue
        }
    }
    
    func remove(index: K, axis: Axis) {
        switch axis {
        case .rows:
            guard let index = self.rowIndexes.firstIndex(of: index) else { fatalError("Unkown index: \(index)") }
            self.rowIndexes.remove(at: index)
            self.rows.remove(at: index)
        case .columns:
            guard let cIndex = self.columnIndexes.firstIndex(of: index) else { fatalError("Unkown index: \(index)") }
            self.columnIndexes.remove(at: cIndex)
            for i in self.rowIndexes {
                self[i].remove(at: index)
            }
        }
    }
    
    func min(axis: Axis) -> Array<T?> {
        let rowsMins = self.rows.map { $0.min() }
        let columnsMins = self.columns.map { $0.min() }
        switch axis {
        case .rows:
            return rowsMins
        case .columns:
            return columnsMins
        }
    }
    
    func max(axis: Axis) -> Array<T?> {
        let rowsMins = self.rows.map { $0.max() }
        let columnsMins = self.columns.map { $0.max() }
        switch axis {
        case .rows:
            return rowsMins
        case .columns:
            return columnsMins
        }
    }
}

extension Matrix: CustomStringConvertible {
    var description: String {
        var desc: String = "  "
        
        for i in self.columnIndexes {
            desc += "  \(i) "
        }
        for i in self.rowIndexes {
            desc += "\n\(i) \(self[i])"
        }
        
        return desc
    }
    
    func info() -> String {
        var infoString = "---INFO---\n- MATRIX:\n\(description)\n"
        
        infoString += "- ROW INDEXES: \(rowIndexes)\n"
        for row in self.rows {
            infoString += "-- \(row.indexes)\n"
        }
        infoString += "- COLUMN INDEXES: \(columnIndexes)\n"
        for column in self.columns {
            infoString += "-- \(column.indexes)\n"
        }

        infoString += "- SIZE: \(size)"
        
        return infoString
    }
}
