import MatrixPower



enum NodeType {
    case include
    case exclude
    case initial
}


class SolverTreeNode {
        
    var matrix: Matrix<Double, Int>
    var point: (Int, Int)
    var currentType: NodeType
    var value: Double
    
    var include: SolverTreeNode?
    var exclude: SolverTreeNode?
    
    init(point: (Int, Int), value: Double, type: NodeType, matrix: Matrix<Double, Int>) {
        self.matrix = matrix
        self.point = point
        self.currentType = type
        self.value = value
    }
}

class SolverTree {
    
    var root: SolverTreeNode!
    var record: Double = Double.infinity
    var points: [(row: Int, column: Int)] = []
    
    func build(matrix: Matrix<Double, Int>) {
        let matrix = self.mockMatrix(matrix: matrix)
    }
    
    func mockMatrix(matrix: Matrix<Double, Int>) -> Matrix<Double, Int> {
        let matrix = matrix.copy()
        for i in matrix.rowIndexes {
            for j in matrix.columnIndexes {
                if i == j {
                    matrix[i][j] = Double.infinity
                }
            }
        }
        return matrix
    }
    
    private func buildHelper(node: SolverTreeNode?) {
        guard let node = node, node.matrix.size != (2, 2) else { return }
        
        let nextPoint = self.getNextPoint(node)
        
        node.include = nextPoint.include
        node.exclude = nextPoint.exclude
        
        self.buildHelper(node: nextPoint.include)
        self.buildHelper(node: nextPoint.exclude)
    }
    
    private func getNextPoint(_ node: SolverTreeNode) -> (include: SolverTreeNode?, exclude: SolverTreeNode?) {
        
        // CHOOSE ZERO POINT
        let (maxZeroIndex, maxZeroValue) = self.getMaxZero(from: node.matrix)
        
        // GET INCLUDE POINT VALUES
        let includePoint = self.getIncludePoint(point: maxZeroIndex, node)
        
        // GET EXCLUDE POINT VALUES
        let excludePoint = self.getExcludePoint(point: maxZeroIndex, value: maxZeroValue, node)
        
        return (include: includePoint, exclude: excludePoint)
    }
    
    func getMaxZero(from matrix: Matrix<Double, Int>) -> ((row: Int, column: Int), Double) {
        var zerosIndexes: Array<(row: Int, column: Int)> = []
        var zerosValues: Array<Double> = []
        
        for i in matrix.rowIndexes {
            for j in matrix.columnIndexes {
                if matrix[i][j] == 0 {
                    zerosIndexes.append((row: i, column:  j))
                    let rowValue = matrix[i].min(except: j)!
                    let columnValue = matrix.T[j].min(except: i)!
                    zerosValues.append(rowValue + columnValue)
                }
            }
        }
        
        let maxValue = zerosValues.max()!
        let maxIndex = zerosValues.firstIndex(of: maxValue)!
        
        return (zerosIndexes[maxIndex], maxValue)
    }
    
    func getIncludePoint(point: (row: Int, column: Int), _ node: SolverTreeNode) -> SolverTreeNode {
        let matrix = node.matrix.copy()
        matrix.remove(index: point.row, axis: .rows)
        matrix.remove(index: point.column, axis: .columns)
        let mockArray = self.ckeckCycles(point: point, matrix: matrix)
        for p in mockArray {
            matrix[p.row][p.column] = Double.infinity
        }
        let result = self.prepare(matrix: matrix)
        let newValue = node.value + result.value
        let newNode = SolverTreeNode(point: point, value: newValue, type: .include, matrix: result.matrix)
        self.points.append(point)
        return newNode
    }

    func getExcludePoint(point: (row: Int, column: Int), value pointValue: Double, _ node: SolverTreeNode) -> SolverTreeNode {
        let matrix = node.matrix.copy()
        matrix[point.row][point.column] = Double.infinity
        let newValue = node.value + pointValue
        let newNode = SolverTreeNode(point: point, value: newValue, type: .exclude, matrix: matrix)
        return newNode
    }
    
    func prepare(matrix: Matrix<Double, Int>) -> (matrix: Matrix<Double, Int>, value: Double) {
        let matrix = matrix.copy()
        
        let rowsMin = matrix.min(axis: .rows).map { $0! }
        for i in 0..<matrix.rowIndexes.count {
            let index = matrix.rowIndexes[i]
            matrix[index] -= rowsMin[i]
        }
        
        let columnsMin = matrix.min(axis: .columns).map { $0! }
        let transposeMatrix = matrix.T.copy()

        for i in 0..<matrix.columnIndexes.count {
            let index = matrix.columnIndexes[i]
            transposeMatrix[index] = transposeMatrix[index] - columnsMin[i]
        }
        return (transposeMatrix.T, rowsMin.reduce(0, +) + columnsMin.reduce(0, +))
    }
    
    func ckeckCycles(point: (row: Int, column: Int), matrix: Matrix<Double, Int>) -> [(row: Int, column: Int)] {
        var cycledArray: [(row: Int, column: Int)] = []
        // FIRST STEP CYCLE
        if matrix.rowIndexes.contains(point.column) && matrix.columnIndexes.contains(point.row) {
            cycledArray.append((row: point.column, column: point.row))
        }
        
        // SECOND STEP CYCLE
        for p in self.points {
            if p.column == point.row, matrix.rowIndexes.contains(point.column) && matrix.columnIndexes.contains(p.row) {
                cycledArray.append((row: point.column, column: p.row))
            }
        }
        
        return cycledArray
    }
}

