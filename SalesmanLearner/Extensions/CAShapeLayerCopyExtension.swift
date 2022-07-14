//
//  CAShapeLayerCopyExtension.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 10.06.2022.
//

import Foundation
import QuartzCore

extension CALayer : NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) {
            if let newInstance = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) {
                return newInstance
            }
        }
        fatalError()
    }
}
