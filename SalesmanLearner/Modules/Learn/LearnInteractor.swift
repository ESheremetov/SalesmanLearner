//
//  LearnInteractor.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//

import Foundation
import CoreData
import UIKit


protocol LearnInteractorProtocol {
    func getLectures() async throws -> Array<Lecture>
}


class LearnInteractor: LearnInteractorProtocol {
    
    weak var presenter: LearnPresenterProtocol!
    var service: DataServiceProtocol!
    let managedContext: NSManagedObjectContext
    
    init(presenter: LearnPresenterProtocol) {
        self.presenter = presenter
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get app delegate from interactor!")
        }
        self.managedContext = appDelegate.persistentContainer.viewContext
        
        self.setupService()
    }
    
    private func setupService() {
        let remoteService = RemoteDataService()
        if remoteService.isAlive() {
            self.service = remoteService
        } else {
            self.service = LocalDataService()
        }
    }
    
    func getLectures() async -> Array<Lecture> {
        let data = try? await self.service.getLecturesList(self.managedContext)
        return data ?? []
    }
}
