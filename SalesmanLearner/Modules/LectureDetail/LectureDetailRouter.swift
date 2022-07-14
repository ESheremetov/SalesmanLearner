//
//  LectureDetailRouter.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 09.06.2022.
//

import Foundation
import UIKit

protocol LectureDetailRouterProtocol {
    func dismiss()
    func willDismiss()
}

class LectureDetailRouter: LectureDetailRouterProtocol {
    
    weak var viewController: LectureDetailViewController!
    
    init(viewController: LectureDetailViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        self.viewController.dismiss(animated: true, completion: nil)
    }
    
    func willDismiss() {
        guard let tabBarController = self.viewController.presentingViewController as? UITabBarController else { return }
        if let presenter = tabBarController.selectedViewController as? LearnViewController {
            presenter.updateTableView()
        }
    }
}
