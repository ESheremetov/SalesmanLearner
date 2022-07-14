//
//  Lecture+CoreDataProperties.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//
//

import Foundation
import CoreData


extension Lecture {

    @nonobjc public class func fetchAllRequest(sort: [NSSortDescriptor]) -> NSFetchRequest<Lecture> {
        let request = NSFetchRequest<Lecture>(entityName: "Lecture")
        request.sortDescriptors = sort
        return request
    }
    
    @nonobjc public class func fetchItemRequest(by predicate: NSPredicate) -> NSFetchRequest<Lecture> {
        let request = NSFetchRequest<Lecture>(entityName: "Lecture")
        request.predicate = predicate
        return request
    }

    @NSManaged public var title: String?
    @NSManaged public var short: String?
    @NSManaged public var long: String?
    @NSManaged public var id: Int32
    @NSManaged public var isDone: Bool
}

extension Lecture : Identifiable {

}
