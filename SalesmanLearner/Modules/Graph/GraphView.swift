//
//  GraphView.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 12.06.2022.
//

import UIKit

class GraphView: UIView {
    
    private var circlesRadius: CGFloat = 15.0
    
    var circlesLayer: CAShapeLayer = CAShapeLayer()
    var linesLayer: CAShapeLayer = CAShapeLayer()
    
    func setupDrawLayers() {
        self.layer.addSublayer(linesLayer)
        self.layer.addSublayer(circlesLayer)
    }

    func drawPoint(at position: CGPoint) {
        let circlePath = UIBezierPath(arcCenter: position,
                                      radius: self.circlesRadius,
                                      startAngle: 0.0, endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "\(Int(position.x))-\(Int(position.y))"
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.yellow.cgColor
        shapeLayer.strokeColor = UIColor(named: "AccentColor")!.cgColor
        shapeLayer.lineWidth = 1.0

        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        shapeLayer.shadowOpacity = 0.7
        shapeLayer.shadowRadius = 1.5
        
        self.circlesLayer.addSublayer(shapeLayer)
    }
    
    func clear() {
        self.circlesLayer.sublayers = []
        self.linesLayer.sublayers = []
    }
    
    func clearAllAnimations() {
        guard let sublayers = self.circlesLayer.sublayers else { return }
        for layer in sublayers {
            layer.removeAllAnimations()
        }
    }
    
    func closetsLayerItem(to point: CGPoint) -> CAShapeLayer? {
        guard let sublayers = self.circlesLayer.sublayers else { return nil }
        var closestPoint: CAShapeLayer? = nil
        var minDistance = Double.infinity
        for layer in sublayers {
            let layer = layer as! CAShapeLayer
            let layerPoint = layer.path!.currentPoint
            let currentDistance = sqrt(pow(layerPoint.x - point.x, 2) + pow(layerPoint.y - point.y, 2))
            if currentDistance < minDistance {
                closestPoint = layer
                minDistance = currentDistance
            }
        }
        return closestPoint
    }
    
    func animateItem(at point: CGPoint) {
        guard let layer = self.closetsLayerItem(to: point) else { return }
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = 1.0
        lineWidthAnimation.toValue = 5.0
        lineWidthAnimation.duration = 1
        lineWidthAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineWidthAnimation.fillMode = .both
        lineWidthAnimation.repeatCount = .greatestFiniteMagnitude
        lineWidthAnimation.autoreverses = true
        lineWidthAnimation.isRemovedOnCompletion = false

        layer.add(lineWidthAnimation, forKey: lineWidthAnimation.keyPath)
    }
    
    func drawConnection(from firstPoint: CGPoint, to secondPoint: CGPoint, distance: CGFloat) -> CATextLayer {
        let linePath = UIBezierPath()
        linePath.move(to: firstPoint)
        linePath.addLine(to: secondPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath

        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.lineWidth = 2.5
        
        
        let distanceLayer = CATextLayer()
        
        let offsetX = firstPoint.x > secondPoint.x ? 0.0 : -35.0
        let offsetY = firstPoint.y > secondPoint.y ? -20.0 : 0.0
        
        distanceLayer.frame = CGRect(x: (firstPoint.x + secondPoint.x) / 2 + offsetX,
                                     y: (firstPoint.y + secondPoint.y) / 2 + offsetY,
                                     width: 35.0, height: 20.0)
        
        distanceLayer.name = "d: \(Int(distance))\(UUID())"
        distanceLayer.string = "\(Int(distance))"
        distanceLayer.foregroundColor = UIColor.black.cgColor
        distanceLayer.fontSize = 15.0
        distanceLayer.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1).cgColor
        distanceLayer.alignmentMode = .center
        distanceLayer.cornerRadius = 5.0
        distanceLayer.shadowColor = UIColor.black.cgColor
        distanceLayer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        distanceLayer.shadowOpacity = 0.7
        distanceLayer.shadowRadius = 1.5
        
        self.linesLayer.addSublayer(distanceLayer)
        self.linesLayer.addSublayer(shapeLayer)
        
        return distanceLayer
    }
    
    func setTextLayerString(for name: String, value: String) {
        for i in 0..<self.linesLayer.sublayers!.count {
            if let layer = self.linesLayer.sublayers![i] as? CATextLayer {
                if layer.name == name {
                    layer.string = value
                    return
                }
            }
        }
    }

}
