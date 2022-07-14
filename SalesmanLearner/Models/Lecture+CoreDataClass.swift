//
//  Lecture+CoreDataClass.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//
//

import Foundation
import CoreData


public class Lecture: NSManagedObject {

    @nonobjc public class func fetchAll(_ context: NSManagedObjectContext) async throws -> Array<Lecture> {
        let sort = [NSSortDescriptor(key: "id", ascending: true)]
        let request = self.fetchAllRequest(sort: sort)
        let data = try? context.fetch(request)
        return data ?? []
    }
    
    @nonobjc public class func fetchItem(by lectureId: Int32, _ context: NSManagedObjectContext) async throws -> Lecture? {
        let predicate = NSPredicate(format: "id == %@", NSNumber(value: lectureId))
        let request = self.fetchItemRequest(by: predicate)
        let data = try? context.fetch(request)
        return data?.first
    }
    
    func save() async throws {
        try self.managedObjectContext?.save()
    }
}
