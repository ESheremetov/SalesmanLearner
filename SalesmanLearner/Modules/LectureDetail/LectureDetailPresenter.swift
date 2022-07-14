//
//  LectureDetailPresenter.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 09.06.2022.
//

import Foundation


protocol LectureDetailPresenterProtocol: AnyObject {
    
    var view: LectureDetailViewController! { get set }
    var interactor: LectureDetailInteractorProtocol! { get set }
    var router: LectureDetailRouterProtocol! { get set }
    
    func configureView()
    func backButtonTapped()
    func getNumberOfCells() -> Int
    func getCellData(by index: Int) -> Array<String>
    func lectureIsDone()
    func viewWillDismiss()
    func updateTextView()
}


class LectureDetailPresenter: LectureDetailPresenterProtocol {
    
    weak var view: LectureDetailViewController!
    var interactor: LectureDetailInteractorProtocol!
    var router: LectureDetailRouterProtocol!
    
    private var numberOfCells: Int = 0
    private var cellsData: Array<Array<String>> = []
    
    private var lecture: Lecture! {
        didSet {
            DispatchQueue.main.sync { [weak self] in
                guard let self = self else { return }
                self.view.lectureTitleLabel.text = self.lecture.title
                self.view.lectureIdLabel.text = "Lecture #\(self.lecture.id)"
            }
        }
    }
    
    required init(view: LectureDetailViewController) {
        self.view = view
    }
    
    func configureView() {
        Task.init { [weak self] in
            
            guard let self = self else { return }
            
            guard let lectureId = UserDefaults.standard.value(forKey: "selectedLecture") as? Int32 else {
                fatalError("There is no selected lecture to perform!")
            }
            
            guard let selectedLecture = await self.interactor.getLecture(by: lectureId) else {
                fatalError("Can not load lecture by id: \(lectureId)")
            }
            
            self.lecture = selectedLecture
            
            self.prepareCells()
            
            DispatchQueue.main.async {
                self.updateTextView()
            }
        }
    }
    
    func backButtonTapped() {
        self.router.dismiss()
    }
    
    func prepareCells() {
        guard let longText = self.lecture.long else { return }
        
        let cellsSeparationArray = longText.components(separatedBy: "<nl>")
        self.numberOfCells = cellsSeparationArray.count
                
        for cellData in cellsSeparationArray {
            self.cellsData.append(self.separateString(cellData))
        }
    }
    
    func separateString(_ string: String) -> [String] {
        var stringElements = Array<String>()
        let currentElement: Array<String> = string.components(separatedBy: "<i>")
        for subElement in currentElement {
            for e in subElement.components(separatedBy: "</i>") {
                stringElements.append(e)
            }
        }
        return stringElements
    }
    
    func getNumberOfCells() -> Int {
        return self.numberOfCells
    }
    
    func getCellData(by index: Int) -> Array<String> {
        return self.cellsData[index]
    }
    
    func updateTextView() {
        self.view.updateTextView(with: self.cellsData)
    }
    
    func lectureIsDone() {
        Task.init { [weak self] in
            guard let self = self else { return }
            self.lecture.isDone = true
            do {
                try await self.lecture.save()
            } catch {
                fatalError("Can't save the \(self.lecture.id)-th lectures object")
            }
        }
    }
    
    func viewWillDismiss() {
        self.router.willDismiss()
    }
}
