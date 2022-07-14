//
//  LearnConfigurator.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//

import Foundation

protocol LearnConfiguratorProtocol: AnyObject {
    
    func configure(with viewController: LearnViewController)
}

class LearnConfigurator: LearnConfiguratorProtocol {
    
    func configure(with viewController: LearnViewController) {
        let presenter = LearnPresenter(view: viewController)
        let interactor = LearnInteractor(presenter: presenter)
        let router = LearnRouter(viewController: viewController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
