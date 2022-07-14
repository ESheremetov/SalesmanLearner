//
//  LearnRouter.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//

import Foundation
import UIKit

protocol LearnRouterProtocol: AnyObject {
    func showDetailedView(for lecture: Lecture)
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}


class LearnRouter: LearnRouterProtocol {
    
    weak var viewController: LearnViewController!
    
    init(viewController: LearnViewController) {
        self.viewController = viewController
    }
    
    func showDetailedView(for lecture: Lecture) {
        self.viewController.performSegue(withIdentifier: "lectureDetailSegue", sender: nil)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lectureDetailSegue" {
            guard segue.destination as? LectureDetailViewController != nil,
                  let lecture = self.viewController.selectedLecture else { return }
            UserDefaults.standard.set(lecture.id, forKey: "selectedLecture")
        }
    }
}
