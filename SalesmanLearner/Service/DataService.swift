//
//  DataService.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//

import Foundation
import CoreData


protocol DataServiceProtocol {
    func getLecturesList(_ context: NSManagedObjectContext) async throws -> Array<Lecture>
    func getLecture(by lectureId: Int32, _ context: NSManagedObjectContext) async throws -> Lecture?
}


class LocalDataService: DataServiceProtocol {
    
    static let fileName: String = "lectures.json"
    
    func getLecture(by lectureId: Int32, _ context: NSManagedObjectContext) async throws -> Lecture? {
        return try? await Lecture.fetchItem(by: lectureId, context)
    }
    
    func getLecturesList(_ context: NSManagedObjectContext) async throws -> Array<Lecture> {
        let localData = try? await Lecture.fetchAll(context)
        guard let localData = localData else { return [] }
        var newLocalData: Array<Lecture> = []
        if localData.isEmpty {
            newLocalData = self.initDataFrom(LocalDataService.fileName, with: context)
        } else {
            newLocalData = localData
        }
        return newLocalData
    }
    
    func initDataFrom(_ file: String, with context: NSManagedObjectContext) -> Array<Lecture> {
        var localData: Array<Lecture> = []
        let lectures: Array<TransportLectureModel> = Bundle.main.decode(file)
        for lecture in lectures {
            let newLecture: Lecture = Lecture(context: context)
            
            newLecture.id = Int32(lecture.id)
            newLecture.short = lecture.short
            newLecture.long = lecture.long
            newLecture.title = lecture.title
            
            localData.append(newLecture)
        }
        do {
            try context.save()
        } catch {
            fatalError("Unable to save data to the local storage.")
        }
        return localData
    }
}


class RemoteDataService: DataServiceProtocol {
    
    func getLecture(by lectureId: Int32, _ context: NSManagedObjectContext) async throws -> Lecture? {
        let lecture = Lecture()
        return lecture
    }
    
    func getLecturesList(_ context: NSManagedObjectContext) async throws -> Array<Lecture>  {
        return []
    }
    
    func isAlive() -> Bool {
        return false
    }
}
