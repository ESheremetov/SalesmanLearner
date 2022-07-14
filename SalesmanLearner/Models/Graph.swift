//
//  Graph.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 12.06.2022.
//

import Foundation
import UIKit


class PointConverter {
    
    var maxValueX: CGFloat
    var maxValueY: CGFloat
    var scale: CGFloat
    
    init(x maxX: CGFloat, y maxY: CGFloat, scale: CGFloat) {
        self.maxValueX = maxX
        self.maxValueY = maxY
        self.scale = scale
    }
    
    func convert(_ point: CGPoint) -> CGPoint {
        let x = (point.x * self.scale) / self.maxValueX
        let y = (point.y * self.scale) / self.maxValueY
        
        return CGPoint(x: x, y: y)
    }
    
    func revert(_ point: CGPoint) -> CGPoint {
        let x = (point.x / self.scale) * self.maxValueX
        let y = (point.y / self.scale) * self.maxValueY
        
        return CGPoint(x: x, y: y)
    }
}


class GraphItem: Equatable, CustomStringConvertible {
    
    typealias Connection = (item: GraphItem, distance: CGFloat)
    
    var coordinates: CGPoint
    var connectedTo: Array<Connection> = []
    var description: String {
        return "Point: \(coordinates)"
    }
    
    init(_ coordinates: CGPoint) {
        self.coordinates = coordinates
    }
    
    func connect(to item: GraphItem, _ distance: CGFloat) {
        self.connectedTo.append(Connection(item: item, distance: distance))
    }
    
    func getConnections() -> Array<Connection> {
        return self.connectedTo
    }
    
    static func == (lhs: GraphItem, rhs: GraphItem) -> Bool {
        return lhs.coordinates == rhs.coordinates
    }
}


class Graph: NSCopying {

    var items: Array<GraphItem> = []
    
    var converter: PointConverter
    
    let closeDistance: CGFloat = 20.0
    
    init(converter: PointConverter) {
        self.converter = converter
    }
    
    static func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        return sqrt(pow(first.x - second.x, 2) + pow(first.y - second.y, 2))
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let graphCopy = Graph(
            converter: PointConverter(x: self.converter.maxValueX,
                                      y: self.converter.maxValueY,
                                      scale: self.converter.scale)
        )
        for item in self.items {
            let itemCopy = GraphItem(item.coordinates)
            graphCopy.add(new: itemCopy)
        }
        
        for i in 0..<graphCopy.items.count {
            for ci in 0..<self.items[i].connectedTo.count {
                for j in 0..<graphCopy.items.count {
                    if graphCopy.items[j] == self.items[i].connectedTo[ci].item {
                        graphCopy.items[i].connect(to: graphCopy.items[j], self.items[i].connectedTo[ci].distance)
                    }
                }
            }
        }
        return graphCopy
    }
    
    func clear() {
        self.items = []
    }
    
    func add(new item: GraphItem) {
        self.items.append(item)
    }
    
    func add(new point: CGPoint) {
        let point = self.converter.convert(point)
        let newItem = GraphItem(point)
        self.add(new: newItem)
    }
    
    func get(by index: Int) -> CGPoint {
        let item = self.items[index]
        return self.converter.revert(item.coordinates)
    }
    
    func makeConnection(from firstItem: GraphItem, to secondItem: GraphItem, _ length: CGFloat) {
        firstItem.connect(to: secondItem, length)
    }
    
    func search(_ point: CGPoint) -> GraphItem? {
        for i in 0..<self.items.count {
            let item = self.items[i]
            let distanceValue = Graph.distance(point,
                                               self.converter.revert(item.coordinates))
            if distanceValue < self.closeDistance {
                return item
            }
        }
        return nil
    }
    
    func makeConnection(from firstPoint: CGPoint, to secondPoint: CGPoint) -> CGFloat? {
        guard let firstItem = self.search(firstPoint) else { return nil }
        guard let secondItem = self.search(secondPoint) else { return nil }
        let distanceValue = Graph.distance(self.converter.convert(firstPoint), self.converter.convert(secondPoint))
        firstItem.connect(to: secondItem, distanceValue)
        return distanceValue
    }
    
    func changeConnection(_ value: CGFloat, from firstPoint: CGPoint, to secondPoint: CGPoint) {
        guard let firstItem = self.search(firstPoint) else { return }
        guard let secondItem = self.search(secondPoint) else { return }
        for index in 0..<firstItem.connectedTo.count {
            if firstItem.connectedTo[index].item == secondItem {
                firstItem.connectedTo[index].distance = value
            }
        }
    }
}


