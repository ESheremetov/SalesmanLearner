//
//  GraphConfigurator.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 12.06.2022.
//

import Foundation


protocol GraphConfiguratorProtocol: AnyObject {
    func configure(with viewController: GraphViewController)
}


class GraphConfigurator: GraphConfiguratorProtocol {
    
    func configure(with viewController: GraphViewController) {
        let presenter = GraphPresenter(view: viewController)
//        let interactor = LearnInteractor(presenter: presenter)
//        let router = LearnRouter(viewController: viewController)
        
        viewController.presenter = presenter
//        presenter.interactor = interactor
//        presenter.router = router
    }
}
