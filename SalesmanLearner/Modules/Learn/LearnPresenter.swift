//
//  LearnPresenter.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 06.06.2022.
//

import Foundation
import UIKit


protocol LearnPresenterProtocol: AnyObject {
    
    var lectures: Array<Lecture> { get set }
    var router: LearnRouterProtocol! { get set }
    
    func configureView()
    func lectureSelected(in row: Int)
    func applySearch(filter string: String)
    func needsPrepareFor(for segue: UIStoryboardSegue, sender: Any?)
    func toggleLectureStatus(for lectureId: Int)
}


class LearnPresenter: LearnPresenterProtocol {
    
    weak var view: LearnViewController!
    var router: LearnRouterProtocol!
    
    var interactor: LearnInteractorProtocol!
    
    var lectures = Array<Lecture>()
    
    required init(view: LearnViewController) {
        self.view = view
    }
    
    func configureView() {
        Task.init { [weak self] in
            guard let self = self else { return }
            do {
                self.lectures = try await self.interactor.getLectures()
            } catch {
                self.lectures = []
            }
        }
    }
    
    func lectureSelected(in row: Int) {
        let lecture = self.lectures[row]
        self.view.selectedLecture = lecture
        self.router.showDetailedView(for: lecture)
    }
    
    func applySearch(filter string: String) {
        Task.init { [ weak self ] in
            guard let self = self else { return }
            self.lectures = []
            let string = string.lowercased()
            guard let totalLectures = try? await self.interactor.getLectures() else { return }
            if string.isEmpty || string.replacingOccurrences(of: " ", with: "").isEmpty {
                self.lectures = totalLectures
            } else {
                for lectureIndex in 0..<totalLectures.count {
                    if ("lecture #\(lectureIndex+1)".contains(string)) ||
                        (totalLectures[lectureIndex].title!.lowercased().contains(string)) {
                        self.lectures.append(totalLectures[lectureIndex])
                    }
                }
            }
            await self.view.updateTableView()
        }
    }
    
    func needsPrepareFor(for segue: UIStoryboardSegue, sender: Any?) {
        self.router.prepare(for: segue, sender: sender)
    }
    
    func toggleLectureStatus(for lectureId: Int) {
        Task.init { [ weak self ] in
            guard let self = self else { return }
            let lecture = self.lectures[lectureId]
            lecture.isDone.toggle()
            do {
                try await lecture.save()
            } catch {
                fatalError("Can't save the \(lectureId)-th lectures object")
            }
        }
    }
}
