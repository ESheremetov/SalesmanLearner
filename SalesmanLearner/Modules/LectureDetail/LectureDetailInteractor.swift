//
//  LectureDetailInteractor.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 09.06.2022.
//

import Foundation
import CoreData
import UIKit


protocol LectureDetailInteractorProtocol: AnyObject {
    func getLecture(by lectureId: Int32) async -> Lecture?
}


class LectureDetailInteractor: LectureDetailInteractorProtocol {
    
    weak var presenter: LectureDetailPresenterProtocol!
    let managedContext: NSManagedObjectContext
    
    init(presenter: LectureDetailPresenterProtocol) {
        self.presenter = presenter
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get app delegate from interactor!")
        }
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getLecture(by lectureId: Int32) async -> Lecture? {
        return try? await Lecture.fetchItem(by: lectureId, self.managedContext)
    }
    
}
