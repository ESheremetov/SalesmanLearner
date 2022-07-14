//
//  LectureDetailConfigurator.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 09.06.2022.
//

import Foundation


protocol LectureDetailConfiguratorProtocol: AnyObject {
    func configure(with viewController: LectureDetailViewController)
}

class LectureDetailConfigurator: LectureDetailConfiguratorProtocol {
    
    func configure(with viewController: LectureDetailViewController) {
        let presenter = LectureDetailPresenter(view: viewController)
        let interactor = LectureDetailInteractor(presenter: presenter)
        let router = LectureDetailRouter(viewController: viewController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}


