//
//  GraphPresenter.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 12.06.2022.
//

import Foundation
import UIKit


enum DrawMode {
    case add
    case connect
    case none
}

enum HistoryOperation {
    case initialization
    case add
    case connect
    case clear
}


protocol GraphPresenterProtocol {
    func configureView()
    func drawObject(at position: CGPoint)
    func modeButtonTapped(_ mode: DrawMode, for button: UIButton)
    func clearButtonTapped()
    func undoButtonTapped()
    func solveButtonTapped()
    func redraw()
    func changeConnectionDistance(_ value: CGFloat, firstPoint: CGPoint, secondPoint: CGPoint)
}


class GraphPresenter: GraphPresenterProtocol {
    
    weak var view: GraphViewController!
    
    private var drawMode: DrawMode = .none
    private var graph: Graph
    private var converter: PointConverter
    private var history: Array<Graph> = []
        
    private var lastPosition: CGPoint? {
        didSet {
            guard let item = self.graph.search(self.lastPosition!) else { return }
            self.view.animatePosition(at: self.graph.converter.revert(item.coordinates))
        }
    }
    
    required init(view: GraphViewController) {
        self.view = view
        self.converter = PointConverter(x: self.view.graphView.bounds.width,
                                        y: self.view.graphView.bounds.height,
                                        scale: 20.0)
        self.graph = Graph(converter: converter)
    }
    
    
    func configureView() {
    }
        
    private func updateConverter() {
        self.graph.converter.maxValueX = self.view.graphView.frame.width
        self.graph.converter.maxValueY = self.view.graphView.frame.height
    }
    
    func drawObject(at position: CGPoint) {
        switch self.drawMode {
        case .add:
            self.save()
            self.addModeAction(at: position)
        case .connect:
            self.save()
            self.connectModeAction(at: position)
        case .none:
            self.noneModeAction(at: position)
        }
    }
    
    func addModeAction(at position: CGPoint) {
        self.updateConverter()
        self.graph.add(new: position)
        self.view.drawPoint(at: position)
        self.lastPosition = position
    }
    
    func connectModeAction(at position: CGPoint) {
        guard let lastPosition = lastPosition else { return }
        guard let firstPoint = self.graph.search(lastPosition) else { return }
        guard let secondPoint = self.graph.search(position) else { return }
        guard firstPoint != secondPoint else { return }
        let firstCoords = self.graph.converter.revert(firstPoint.coordinates)
        let secondCoords = self.graph.converter.revert(secondPoint.coordinates)
        guard let distance = self.graph.makeConnection(from: firstCoords, to: secondCoords) else { return }
        self.view.drawConnection(from: firstCoords,
                                 to: secondCoords,
                                 distance: distance)
        self.lastPosition = position
    }
    
    func changeConnectionDistance(_ value: CGFloat, firstPoint: CGPoint, secondPoint: CGPoint) {
        self.graph.changeConnection(value, from: firstPoint, to: secondPoint)
    }
    
    func noneModeAction(at position: CGPoint) {
        if let sublayers = self.view.graphView.linesLayer.sublayers {
            for layer in sublayers {
                if let textLayer = layer.hitTest(position) as? CATextLayer {
                    self.view.showPickerView(with: textLayer.name!)
                }
            }
        }

        guard let item = self.graph.search(position) else { return }
        if self.graph.converter.revert(item.coordinates) == self.lastPosition {
            self.view.clearAllAnimations()
        } else {
            self.lastPosition = self.graph.converter.revert(item.coordinates)
        }
    }
    
    func modeButtonTapped(_ mode: DrawMode, for button: UIButton) {
        if self.drawMode == mode {
            self.drawMode = .none
            self.view.buttonTappedStyle(for: button, tapped: false)
        } else {
            self.drawMode = mode
            self.view.clearButtonsStyle()
            self.view.buttonTappedStyle(for: button, tapped: true)
        }
    }
    
    func clearButtonTapped() {
        self.save()
        self.graph.clear()
        self.view.clearView()
    }
    
    func save() {
        self.history.append(self.graph.copy() as! Graph)
    }
    
    func undoButtonTapped() {
        self.graph = self.history.popLast() ?? self.graph
        self.redraw()
    }
    
    func redraw() {
        self.view.clearView()
        self.updateConverter()

        
        for index in 0..<self.graph.items.count {
            let revertedPoint = self.graph.get(by: index)
            self.view.drawPoint(at: revertedPoint)
        }
        
        for index in 0..<self.graph.items.count {
            let point = self.graph.items[index]
            for connection in point.getConnections() {
                let connectionItem = connection.item
                let conncetionDistance = connection.distance
                self.view.drawConnection(from: self.graph.converter.revert(point.coordinates),
                                         to: self.graph.converter.revert(connectionItem.coordinates),
                                         distance: conncetionDistance)
            }
        }
    }
    
    func solveButtonTapped() {
        
    }
}
